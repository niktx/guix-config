(define-module (n1ks home services legendary)
  #:use-module (gnu home services)
  #:use-module (gnu services configuration)
  #:use-module (guix gexp)
  #:use-module (n1ks packages legendary)
  #:export (home-legendary-service-type))

(define-configuration home-legendary-configuration)

(define %legendary-config
  (string-append
    "[default]
wine_executable = wine64

[default.env]
WINEDEBUG = -all

[Sugar] ; Rocket League
wine_prefix = " (getenv "HOME") "/Games/wine-prefixes/rocketleague
"))

(define (add-legendary-configuration config)
  `(("config/legendary/config.ini" ,(plain-file "legendary-config" %legendary-config))))

(define (add-legendary-packages config)
  (list legendary))

(define home-legendary-service-type
  (service-type
   (name 'home-legendary)
   (description "Install and configure legendary.")
   (extensions
    (list (service-extension home-files-service-type
                             add-legendary-configuration)
          (service-extension home-profile-service-type
                             add-legendary-packages)))
   (default-value (home-legendary-configuration))))
