(define-module (n1ks services coturn)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (n1ks packages coturn)
  #:export (coturn-configuration
            coturn-configuration?
            coturn-service-type))

(define (file-name? val)
  (and (string? val)
       (string-prefix? "/" val)))

(define (string-list? val)
  (and (list? val)
       (and-map string? val)))

(define-configuration/no-serialization coturn-configuration
  (coturn
   (package coturn)
   "The coturn package.")
  (pid-file
   (file-name "/var/run/turnserver.pid")
   "Path to the pid file.")
  (user
   (string "coturn")
   "The coturn user.")
  (group
   (string "coturn")
   "The coturn group.")
  (extra-config
   (string-list '())
   "Additional configuration."))

(define (coturn-config-file config)
  (string-join (coturn-configuration-extra-config config) "\n"))

(define (coturn-directory config)
  (computed-file "etc-coturn"
                 #~(begin
                     (mkdir #$output)
                     (chdir #$output)
                     (call-with-output-file "turnserver.conf"
                       (lambda (port)
                         (display #$(coturn-config-file config)
                                  port))))))

(define (coturn-etc-service config)
  `(("coturn" ,(coturn-directory config))))

(define (coturn-account-service config)
  (let ((user (coturn-configuration-user config))
        (group (coturn-configuration-group config)))
    (list (user-group
           (name group)
           (system? #t))
          (user-account
           (name user)
           (group group)
           (comment "coturn privilege seperation user")
           (home-directory (string-append "/var/run/" user))
           (shell (file-append shadow "/sbin/nologin"))
           (system? #t)))))

(define (coturn-shepherd-service config)
  "Return a <shepherd-service> for coturn with CONFIG."
  (let ((turnserver (file-append (coturn-configuration-coturn config)
                                 "/bin/turnserver"))
        (pid-file (coturn-configuration-pid-file config)))
    (list (shepherd-service
           (documentation "TURN server.")
           (requirement '(syslogd networking))
           (provision '(coturn))
           (start #~(make-forkexec-constructor
                     (list #$turnserver "-c" "/etc/coturn/turnserver.conf")
                     #:pid-file #$pid-file))
           (stop #~(make-kill-destructor))))))

(define coturn-service-type
  (service-type
   (name 'coturn)
   (description "Run the coturn TURN server, @command{turnserver}.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             coturn-shepherd-service)
          (service-extension etc-service-type
                             coturn-etc-service)
          (service-extension account-service-type
                             coturn-account-service)))
   (default-value (coturn-configuration))))
