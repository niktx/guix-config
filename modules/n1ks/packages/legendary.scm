(define-module (n1ks packages legendary)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-build)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system python)
  #:use-module (nonguix build-system binary))

(define-public legendary
  (package
    (name "legendary")
    (version "0.20.10")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "legendary-gl" version))
        (sha256 (base32 "02kqr5cs6dg2v5crlxhjihsbshi52lcksc617c26xsrh065qq1jy"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'check))))
    (propagated-inputs
     `(("python-requests" ,python-requests)
       ("python-wheel" ,python-wheel)))
    (synopsis "A free and open-source replacement for the Epic Games Launcher")
    (description "Legendary is an open-source game launcher that can download
and install games from the Epic Games platform on Linux and Windows.")
    (home-page "https://github.com/derrod/legendary")
    (license license:gpl3)))
