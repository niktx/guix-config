(define-module (n1ks home-services xmodmap)
  #:use-module (gnu services)
  #:use-module (gnu home-services files)
  #:use-module (guix gexp)
  #:export (home-xmodmap-service))

(define %xmodmap-config
  "keycode 110 = XF86AudioPrev
keycode 115 = XF86AudioPlay
keycode 118 = XF86AudioNext")

(define %xmodmap-script
  "#!/bin/sh
xmodmap ~/.Xmodmap")

(define home-xmodmap-service
  (simple-service
   'xmodmap-config home-files-service-type
   `(("Xmodmap" ,(plain-file "xmodmap-config" %xmodmap-config))
     ("xmodmap.sh" ,(plain-file "xmodmap-script" %xmodmap-script)))))
