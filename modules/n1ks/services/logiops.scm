(define-module (n1ks services logiops)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)
  #:use-module (n1ks packages logiops)
  #:export (logiops-configuration
            logiops-configuration?
            logiops-service-type))

(define (file-path? val)
  (and (string? val)
       (string-prefix? "/" val)))

(define (logiops-log-level? val)
  (or (eq? val 'debug)
      (eq? val 'info)
      (eq? val 'warn)
      (eq? val 'error)))

(define-maybe/no-serialization file-like)

(define-configuration/no-serialization logiops-configuration
  (logiops
   (package logiops)
   "The logiops package.")
  (log-file
   (file-path "/var/log/logiops.log")
   "The path to the log file.")
  (log-level
   (logiops-log-level 'debug)
   "The log level. Valid values are @code{'debug}, @code{'info}, @code{'warn},
and @code{'error}.")
  (config-file
   (maybe-file-like 'disabled)
   "The configuration file."))

(define (logiops-shepherd-service config)
  (let ((logid-command (file-append (logiops-configuration-logiops config)
                                    "/bin/logid"))
        (log-file (logiops-configuration-log-file config))
        (log-level (symbol->string (logiops-configuration-log-level config)))
        (config-file (logiops-configuration-config-file config)))
    (list (shepherd-service
           (documentation "Logiops service.")
           (requirement '(udev))
           (provision '(logiops))
           (start #~(make-forkexec-constructor
                     (list #$logid-command
                           "--verbose" #$log-level
                           #$@(if (eq? config-file 'disabled)
                                  #~()
                                  #~("--config" #$config-file)))
                     #:log-file #$log-file))
           (stop #~(make-kill-destructor))))))

(define logiops-service-type
  (service-type
   (name 'logiops)
   (description "Run @command{logid}.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             logiops-shepherd-service)))
   (default-value (logiops-configuration))))
