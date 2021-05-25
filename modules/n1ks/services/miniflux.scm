(define-module (n1ks services miniflux)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages admin)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services databases)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu system shadow)
  #:use-module (n1ks packages miniflux)
  #:export (miniflux-configuration
            miniflux-configuration?
            miniflux-admin-configuration
            miniflux-admin-configuration?
            miniflux-service-type))

;; TODO: Automate setup
;; At the moment the following commands have to be run manually:
;; * sudo -u postgres psql miniflux -c "ALTER ROLE miniflux WITH PASSWORD '...';"
;; * sudo -u postgres psql miniflux -c "CREATE EXTENSION hstore;"

(define-maybe/no-serialization string)

(define (file-name? val)
  (and (string? val)
       (string-prefix? "/" val)))

(define (string-list? val)
  (and (list? val)
       (and-map string? val)))

(define-configuration/no-serialization miniflux-admin-configuration
  (username
   (string (configuration-missing-field 'miniflux-admin-configuration 'username))
   "The username of the admin user.")
  (password
   (string (configuration-missing-field 'miniflux-admin-configuration 'password))
   "The password of the admin user."))

(define-maybe/no-serialization miniflux-admin-configuration)

(define (admin-environment-variables config)
  (let ((username (miniflux-admin-configuration-username config))
        (password (miniflux-admin-configuration-password config)))
    (list "CREATE_ADMIN=1"
          (string-append "ADMIN_USERNAME=" username)
          (string-append "ADMIN_PASSWORD=" password))))

(define-configuration/no-serialization miniflux-configuration
  (miniflux
   (package miniflux)
   "The miniflux package.")
  (log-file
   (file-name "/var/log/miniflux.log")
   "The path to the log file.")
  (user
   (string "miniflux")
   "Owner of the @code{miniflux} process.")
  (group
   (string "miniflux")
   "Owner's group of the @code{miniflux} process.")
  (password
   (string (configuration-missing-field 'miniflux-configuration 'password))
   "The password of the database user.")
  (run-migrations?
   (boolean #t)
   "Whether to automatically run database migrations.")
  (admin
   (maybe-miniflux-admin-configuration 'disabled)
   "The configuration for the admin user. If set to @code{'disabled}, no admin
user is created.")
  (extra-config
   (string-list '())
   "Additional configuration."))

(define (miniflux-accounts config)
  (let ((user (miniflux-configuration-user config))
        (group (miniflux-configuration-group config))
        (password (miniflux-configuration-password config)))
    (list (user-group
            (name group)
            (system? #t))
          (user-account
            (name user)
            (group group)
            (comment "miniflux privilege separation user")
            (home-directory (string-append "/var/run/" user))
            (shell (file-append shadow "/sbin/nologin"))
            (system? #t)))))

(define (miniflux-shepherd-service config)
  "Return a <shepherd-service> for miniflux with CONFIG."
  (let* ((user (miniflux-configuration-user config))
         (group (miniflux-configuration-group config))
         (password (miniflux-configuration-password config))
         (log-file (miniflux-configuration-log-file config))
         (miniflux-command (file-append (miniflux-configuration-miniflux config)
                                        "/bin/miniflux"))
         (database-url (string-append "user=" user " password=" password
                                      " dbname=" user " sslmode=disable"))
         (run-migrations? (miniflux-configuration-run-migrations? config))
         (admin (miniflux-configuration-admin config))
         (extra-config (miniflux-configuration-extra-config config)))
    (list (shepherd-service
            (documentation "Miniflux server.")
            (provision '(miniflux))
            (requirement '(networking postgres postgres-roles))
            (start
              #~(make-forkexec-constructor
                  (list #$miniflux-command)
                  #:user #$user
                  #:group #$group
                  #:log-file #$log-file
                  #:environment-variables
                  (list
                    #$(string-append "DATABASE_URL=" database-url)
                    #$@(if run-migrations? '("RUN_MIGRATIONS=1") '())
                    #$@(if (eq? admin 'disabled)
                           '()
                           (admin-environment-variables admin))
                    #$@extra-config)))
            (stop #~(make-kill-destructor))))))

(define (miniflux-postgresql-roles config)
  (let ((user (miniflux-configuration-user config)))
    (list (postgresql-role
            (name user)
            (create-database? #t)))))

(define miniflux-service-type
  (service-type
    (name 'miniflux)
    (description "Run the miniflux server.")
    (extensions
      (list (service-extension shepherd-root-service-type
                               miniflux-shepherd-service)
            (service-extension account-service-type
                               miniflux-accounts)
            (service-extension postgresql-role-service-type
                               miniflux-postgresql-roles)))))
