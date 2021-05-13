(define-module (rust-ext)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (guix packages)
  #:use-module (guix download)
  ;; #:use-module (gnu packages rust) ;; Used for clippy package
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public rust-src
  (package
    (name "rust-src")
    (version "1.51.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://static.rust-lang.org/dist/2021-03-25/rust-src-"
                            version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "0qqm60s9x0nhrab18m9rlz1hpihvc4f3jcldm2hrzh2v9jh4r40q"))))
    (build-system binary-build-system)
    (arguments
     `(#:install-plan
       `(("rust-src/lib" "./"))))
    (synopsis "Source for the Rust programming language")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))

;; (define-public rust-clippy-bin
;;   (package
;;     (name "rust-clippy-bin")
;;     (version "1.50.0")
;;     (source
;;       (origin
;;         (method url-fetch)
;;         (uri (string-append "https://static.rust-lang.org/dist/2021-02-11/clippy-"
;;                             version "-x86_64-unknown-linux-gnu.tar.gz"))
;;         (file-name (string-append name "-" version ".tar.gz"))
;;         (sha256 (base32 "0f7am39k5zzvlpifjv2diz7gv5ya2g2p0cx601ikcrwxngyrhh7g"))))
;;     (build-system binary-build-system)
;;     (arguments
;;      `(#:patchelf-plan
;;        `(("clippy-preview/bin/cargo-clippy"
;;           ("glibc" "gcc:lib"))
;;          ("clippy-preview/bin/clippy-driver"
;;           ("gcc:lib" "rust")))
;;        #:install-plan
;;        `(("clippy-preview/bin" "bin")
;;          ("clippy-preview/share" "share"))))
;;     (inputs
;;      `(("glibc" ,glibc)
;;        ("gcc:lib" ,gcc "lib")
;;        ("rust" ,rust-1.50)))
;;     (home-page "https://github.com/rust-lang/rust-clippy")
;;     (synopsis "Lints to avoid common pitfalls in Rust")
;;     (description "This package provides a bunch of helpful lints to avoid common
;; pitfalls in Rust.")
;;     (license (list license:expat license:asl2.0))))

(define-public rust-analyzer-bin
  (package
    (name "rust-analyzer-bin")
    (version "2021-03-29")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/rust-analyzer/rust-analyzer/releases/download/"
                            version "/rust-analyzer-x86_64-unknown-linux-gnu.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "14id5ab2zzzlkca0m28bagj7ghhgwprdx31lgdn0pf35z27425z0"))))
    (build-system binary-build-system)
    (arguments
     `(#:patchelf-plan
       `(("rust-analyzer"
          ("glibc" "gcc:lib")))
       #:install-plan
       `(("rust-analyzer" "bin/"))
       #:phases
       (modify-phases %standard-phases
         (replace 'unpack
           (lambda* (#:key source #:allow-other-keys)
             (invoke "sh" "-c" (string-append "gunzip -cf '" source "' > rust-analyzer"))
             (chmod "rust-analyzer" #o755))))))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")))
    (synopsis "An experimental Rust compiler front-end for IDEs (binary package)")
    (description "Rust-analyzer is an experimental modular compiler frontend for the Rust language.")
    (home-page "https://rust-analyzer.github.io")
    (license (list license:asl2.0 license:expat))))
