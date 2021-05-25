(define-module (n1ks home-services tig)
  #:use-module (gnu services)
  #:use-module (gnu home-services files)
  #:use-module (guix gexp)
  #:export (home-tig-service))

(define %tig-config
  "color cursor black green bold
color title-focus black blue bold
bind status P !git push origin")

(define home-tig-service
  (simple-service
   'tig-config home-files-service-type
   `(("config/tig/config" ,(plain-file "tig-config" %tig-config)))))
