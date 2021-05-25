(define-module (n1ks packages rust-bin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary)
  #:use-module (n1ks packages rust-ext))

(define-public rust-bin
  (package
    (name "rust-bin")
    (version "1.52.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://static.rust-lang.org/dist/2021-05-06/rust-"
                            version "-x86_64-unknown-linux-gnu.tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "0aqfr9k2p5aln233rsbjv4nkd0l26h81md07fhhgy1hjm3pbb0n0"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
     `(#:patchelf-plan
       `(("rustc/lib/libLLVM-12-rust-1.52.0-stable.so"
          ("glibc" "gcc:lib" "zlib"))
         ("rustc/lib/libstd-627bae978fe79731.so"
          ("glibc" "gcc:lib"))
         ("rustc/lib/librustc_driver-4595c4d4fb03d628.so"
          ("glibc" "gcc:lib" "out"))
         ;; ("rustc/lib/libchalk_derive-61359e51e4358720.so"
         ;;  ("glibc" "gcc:lib"))
         ;; ("rustc/lib/librustc_macros-4fdb095435d7e9cb.so"
         ;;  ("glibc" "gcc:lib"))
         ("rustc/lib/libtest-43069443d3425670.so"
          ("gcc:lib" "out"))
         ;; ("rustc/lib/libtracing_attributes-36f34216659db5d4.so"
         ;;  ("glibc" "gcc:lib"))
         ;; ("rustc/lib/libserde_derive-ebf4f007defb9256.so"
         ;;  ("glibc" "gcc:lib"))
         ("rustc/bin/rustc"
          ("glibc" "out"))
         ("rustc/bin/rustdoc"
          ("gcc:lib" "out"))
         ("rustc/lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-lld"
          ("glibc" "gcc:lib" "out"))
         ("rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libstd-627bae978fe79731.so"
          ("glibc" "gcc:lib"))
         ("rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libtest-43069443d3425670.so"
          ("gcc:lib" "out"))
         ("cargo/bin/cargo"
          ("glibc" "gcc:lib"))
         ("clippy-preview/bin/cargo-clippy"
          ("glibc" "gcc:lib"))
         ("clippy-preview/bin/clippy-driver"
          ("gcc:lib" "out"))
         ("rustfmt-preview/bin/rustfmt"
          ("glibc" "gcc:lib"))
         ("rustfmt-preview/bin/cargo-fmt"
          ("glibc" "gcc:lib")))
       #:phases
       (modify-phases %standard-phases
         (replace 'install
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               ;; rustc
               (delete-file "rustc/lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-lld")
               (delete-file "rustc/lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-llvm-dwp")
               (copy-recursively "rustc/lib" (string-append out "/lib"))
               (copy-recursively "rustc/share" (string-append out "/share"))
               (copy-recursively "rustc/bin" (string-append out "/bin"))
               ;; std
               (copy-recursively "rust-std-x86_64-unknown-linux-gnu/lib" (string-append out "/lib"))
               ;; cargo
               (copy-recursively "cargo/etc" (string-append out "/etc"))
               (copy-recursively "cargo/share" (string-append out "/share"))
               (copy-recursively "cargo/bin" (string-append out "/bin"))
               ;; clippy
               (copy-recursively "clippy-preview/share" (string-append out "/share"))
               (copy-recursively "clippy-preview/bin" (string-append out "/bin"))
               ;; rustfmt
               (copy-recursively "rustfmt-preview/share" (string-append out "/share"))
               (copy-recursively "rustfmt-preview/bin" (string-append out "/bin"))
               ;; rust-docs
               (copy-recursively "rust-docs/share" (string-append out "/share"))
               ;; rust-src
               (copy-recursively (string-append (assoc-ref inputs "rust-src") "/lib")
                                 (string-append out "/lib"))))))))
    (inputs
     `(("glibc" ,glibc)
       ("gcc:lib" ,gcc "lib")
       ("zlib" ,zlib)))
    (native-inputs
     `(("rust-src" ,rust-src)))
    (propagated-inputs
     `(("rust-analyzer-bin" ,rust-analyzer-bin)))
    (synopsis "The Rust programming language (binary package)")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))
