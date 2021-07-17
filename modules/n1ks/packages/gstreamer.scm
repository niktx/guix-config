(define-module (n1ks packages gstreamer)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system meson)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public gstreamer-vaapi
  (package
   (name "gstreamer-vaapi")
   (version "1.18.4")
   (source
    (origin
     (method url-fetch)
     (uri (string-append "https://gstreamer.freedesktop.org/src/"
                         name "/" name "-" version ".tar.xz"))
     (file-name (string-append name "-" version ".tar.xz"))
     (sha256
      (base32
       "1sia4l88z7kkxm2z9j20l43rqkrnsa47xccski10s5gkhsprinwj"))))
   (build-system meson-build-system)
   (arguments
    `(#:configure-flags '("-Dexamples=disabled" "-Ddoc=disabled")
      ;; TODO: Don't skip tests
      #:phases
      (modify-phases %standard-phases
        (delete 'check))))
   (inputs
    `(("gstreamer" ,gstreamer)
      ("gst-plugins-bad" ,gst-plugins-bad)
      ("libva" ,libva)
      ("libxrandr" ,libxrandr)))
   (native-inputs
    `(("pkg-config" ,pkg-config)
      ("cmake" ,cmake)))
   (home-page "https://gstreamer.freedesktop.org")
   (synopsis "Set of VAAPI GStreamer Plug-ins")
   (description "Set of VAAPI GStreamer Plug-ins.")
   (license license:lgpl2.1+)))
