(use-modules
  (ice-9 textual-ports)
  (gnu)
  (n1ks services coturn)
  (n1ks services miniflux))
(use-package-modules databases)
(use-service-modules admin certbot databases dbus docker desktop linux networking ssh web)

(define %nginx-deploy-hook
  (program-file
    "nginx-deploy-hook"
    #~(let ((pid (call-with-input-file "/var/run/nginx/pid" read)))
        (kill pid SIGHUP))))

(operating-system
  (host-name "vps-guix")
  (timezone "Europe/Berlin")
  (locale "en_US.UTF-8")
  (keyboard-layout (keyboard-layout "de"))
  (users (cons (user-account
                 (name "niklas")
                 (comment "Niklas Sauter")
                 (group "users")
                 (home-directory "/home/niklas")
                 (supplementary-groups '("wheel")))
               %base-user-accounts))
  (packages
    (append
      (list (specification->package "nss-certs"))
      %base-packages))
  (services
    (cons*
      (service dhcp-client-service-type)
      (service openssh-service-type
        (openssh-configuration
          (password-authentication? #f)
          (permit-root-login 'without-password)
          (authorized-keys
            `(("niklas" ,(local-file "data/t14-guix.pub")
                        ,(local-file "data/mi9t-android.pub"))
              ("root" ,(local-file "data/t14-guix.pub")
                      ,(local-file "data/mi9t-android.pub"))))))
      (service zram-device-service-type
        (zram-device-configuration (size "2G")))
      (service postgresql-service-type
        (postgresql-configuration
          (postgresql postgresql-13)))
      (service miniflux-service-type
        (miniflux-configuration
          (password (call-with-input-file
                      "data/miniflux-database-password.txt"
                      get-line))
          (admin (miniflux-admin-configuration
                   (username "admin")
                   (password (call-with-input-file
                               "data/miniflux-admin-password.txt"
                               get-line))))
          (extra-config '("LISTEN_ADDR=127.0.0.1:8080"))))
      (service coturn-service-type
        (coturn-configuration
          (extra-config
           `("verbose"
             "simple-log"
             "use-auth-secret"
             ,(string-append "static-auth-secret="
                             (call-with-input-file
                               "data/coturn-auth-secret.txt"
                               get-string-all))
              "server-name=turn.n1ks.net"
              "realm=turn.n1ks.net"
              "cert=/etc/letsencrypt/live/turn.n1ks.net/fullchain.pem"
              "pkey=/etc/letsencrypt/live/turn.n1ks.net/privkey.pem"
              "external-ips=78.47.91.233"
              "denied-peer-ips=10.0.0.0-10.255.255.255"
              "denied-peer-ips=192.168.0.0-192.168.255.255"
              "denied-peer-ips=172.16.0.0-172.31.255.255"
              "allowed-peer-ips=10.0.0.1"
              "user-quota=12"
              "total-quota=1200"))))
      (service certbot-service-type
        (certbot-configuration
          (email "niklas@n1ks.net")
          (certificates
            (list (certificate-configuration
                    (domains '("n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("vault.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("feed.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("searx.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("turn.n1ks.net")))))))
      (service nginx-service-type
        (nginx-configuration
          (server-blocks
            (list ;; Matrix
                  ;; https://github.com/matrix-org/synapse/blob/master/docs/reverse_proxy.md
                  (nginx-server-configuration
                    (server-name '("n1ks.net"))
                    (listen '("443 ssl"
                              "[::]:443 ssl"
                              "8448 ssl default_server"
                              "[::]:8448 ssl default_server"))
                    (ssl-certificate "/etc/letsencrypt/live/n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "~* ^(\\/_matrix|\\/_synapse\\/client|\\/.well-known\\/matrix)")
                          (body '("proxy_pass http://localhost:8008;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"
                                  "client_max_body_size 50M;"))))))

                  ;; Bitwarden
                  ;; https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples
                  (nginx-server-configuration
                    (server-name '("vault.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/vault.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/vault.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:8081;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;")))
                        (nginx-location-configuration
                          (uri "/notifications/hub")
                          (body '("proxy_pass http://localhost:8082;"
                                  "proxy_set_header Upgrade $http_upgrade;"
                                  "proxy_set_header Connection \"upgrade\";")))
                        (nginx-location-configuration
                          (uri "/notifications/hub/negotiate")
                          (body '("proxy_pass http://localhost:8081;")))))
                    (raw-content '("client_max_body_size 128M;")))

                  ;; Miniflux
                  (nginx-server-configuration
                    (server-name '("feed.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/feed.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/feed.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:8080;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"))))))

                  ;; Searx
                  (nginx-server-configuration
                    (server-name '("searx.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/searx.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/searx.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:4040;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"
                                  "proxy_set_header X-Script-Name /searx;")))
                        (nginx-location-configuration
                          (uri "/morty/")
                          (body '("proxy_pass http://localhost:3000;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;")))))
                    (raw-content '("access_log /dev/null;")))))))
      (simple-service 'rotate-nginx-logs
                      rottlog-service-type
                      (list (log-rotation
                             (frequency 'daily)
                             (files '("/var/log/nginx/*")))))

      (dbus-service) ;; Required for `docker-service-type`
      (elogind-service) ;; Required for `docker-service-type`
      (service docker-service-type)
      %base-services))
  (initrd-modules
    (cons "virtio_scsi"
          %base-initrd-modules))
  (bootloader
    (bootloader-configuration
      (bootloader grub-bootloader)
      (target "/dev/sda")))
  (file-systems
    (cons (file-system
            (device (file-system-label "my-drive"))
            (mount-point "/")
            (type "ext4"))
          %base-file-systems)))
