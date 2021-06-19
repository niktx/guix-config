(define-module (n1ks packages logiops)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xorg)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:))

(define-public logiops
  (package
    (name "logiops")
    (version "0.2.3")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://github.com/PixlOne/logiops/archive/refs/tags/v"
               version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256
          (base32 "13zqail1hl1yjkwail92lhjcfk4rlqd3jvryllglcpg7qnn7q525"))))
    (build-system cmake-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'check))))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("eudev" ,eudev)
       ("libconfig" ,libconfig)
       ("libevdev" ,libevdev)))
    (home-page "https://github.com/PixlOne/logiops")
    (synopsis "An unofficial userspace driver for HID++ Logitech devices")
    (description "An unofficial userspace driver for HID++ Logitech devices.")
    (license license:gpl3)))
