(define-module (n1ks packages miniflux)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public miniflux
  (package
    (name "miniflux")
    (version "2.0.30")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/miniflux/v2/releases/download/"
                            version "/miniflux-linux-amd64"))
        (file-name (string-append name "-" version ".bin"))
        (sha256 (base32 "00rvcfnwzdk3x2b0a995xl57dkd42r8wjm2rgswz19mins9rq2cz"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
     `(#:install-plan
       `(("miniflux" "bin/"))
       #:phases
       (modify-phases %standard-phases
         (replace 'unpack
           (lambda* (#:key source #:allow-other-keys)
             (copy-file source "miniflux")
             (chmod "miniflux" #o755))))))
    (home-page "https://miniflux.app")
    (synopsis "Minimalist and opinionated feed reader")
    (description "Miniflux is a minimalist and opinionated feed reader.")
    (license license:asl2.0)))
