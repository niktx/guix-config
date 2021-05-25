(define-module (n1ks packages mdbook)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public mdbook
  (package
    (name "mdbook")
    (version "0.4.7")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/rust-lang/mdBook/releases/download/v"
                            version "/mdbook-v" version "-x86_64-unknown-linux-gnu.tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "1ca61akrgs2ph7pyzgmyw59wgdzjb9jc9647n3az00xmyd0ms7vg"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
     `(#:patchelf-plan
       `(("mdbook"
          ("glibc" "gcc:lib")))
       #:install-plan
       `(("mdbook", "bin/"))
       #:phases
       (modify-phases %standard-phases
         (replace 'unpack
           (lambda* (#:key source #:allow-other-keys)
             (invoke "sh" "-c" (string-append "tar xvzf '" source "' > mdbook"))
             (chmod "mdbook" #o755))))))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")))
    (synopsis "Create book from markdown files")
    (description "mdBook is a utility to create modern online books from
Markdown files.")
    (home-page "https://github.com/rust-lang/mdBook")
    (license license:mpl2.0)))
