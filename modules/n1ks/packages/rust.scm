(define-module (n1ks packages rust)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public rust-src
  (package
    (name "rust-src")
    (version "1.52.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://static.rust-lang.org/dist/2021-05-06/rust-src-"
                            version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "09z2z5in9hxzcyp39g80msjbsg25ryxsbzisbrdwmypjzbqwn7c6"))))
    (build-system binary-build-system)
    (arguments
     `(#:install-plan
       `(("rust-src/lib" "./"))))
    (synopsis "Source for the Rust programming language")
    (description "Source for the Rust programming language")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))
