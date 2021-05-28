(define-module (n1ks home-services xmodmap)
  #:use-module (gnu home-services)
  #:use-module (gnu home-services files)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:export (home-xmodmap-service-type))

(define-configuration home-xmodmap-configuration)

(define %xmodmap-config
  "keycode 110 = XF86AudioPrev
keycode 115 = XF86AudioPlay
keycode 118 = XF86AudioNext")

(define %xmodmap-script
  "#!/bin/sh
xmodmap ~/.Xmodmap")

(define (add-xmodmap-configuration config)
  `(("Xmodmap" ,(plain-file "xmodmap-config" %xmodmap-config))
    ("xmodmap.sh" ,(plain-file "xmodmap-script" %xmodmap-script))))

(define (add-xmodmap-packages config)
  (list xmodmap))

(define home-xmodmap-service-type
  (service-type
   (name 'home-xmodmap)
   (description "Install and configure xmodmap.")
   (extensions
    (list (service-extension home-files-service-type
                             add-xmodmap-configuration)
          (service-extension home-profile-service-type
                             add-xmodmap-packages)))
   (default-value (home-xmodmap-configuration))))
