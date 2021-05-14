(define-module (kakoune-xyz)
  #:use-module (gnu packages)
  #:use-module (gnu packages crates-io)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages pkg-config)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system cargo)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:))

(define-public kak-tree
  (package
    (name "kak-tree")
    (version "b9dcc885e737cdef2bf5c11f1a3ee967ac680b05")
    (source
      (origin
        (method git-fetch)
        (uri
          (git-reference
            (url "https://github.com/ul/kak-tree")
            (commit version)
            (recursive? #t)))
        (file-name (git-file-name name version))
        (sha256 (base32 "0nsq2qnli8zsvqxgwwrlizcdk9i2013cxc11xssakrvqylx4wbi2"))
        (patches
          (search-patches "patches/kak-tree-new-sloggers-version.patch"))))
    (build-system cargo-build-system)
    (arguments
     `(#:features '("bash" "json" "rust")
       #:cargo-inputs
       (("rust-cc" ,rust-cc-1)
        ("rust-clap" ,rust-clap-2)
        ("rust-itertools" ,rust-itertools-0.8)
        ("rust-serde" ,rust-serde-1)
        ("rust-slog" ,rust-slog-2)
        ("rust-slog-scope" ,rust-slog-scope-4)
        ("rust-sloggers" ,rust-sloggers-1)
        ("rust-toml" ,rust-toml-0.5)
        ("rust-tree-sitter" ,rust-tree-sitter-0.6))))
    (home-page "https://github.com/ul/kak-tree")
    (synopsis "Structural selections for Kakoune")
    (description "kak-tree is a plugin for Kakoune which enables selection of
syntax tree nodes. Parsing is performed with tree-sitter.")
    (license license:unlicense)))

(define-public rust-tree-sitter-0.6
  (package
    (name "rust-tree-sitter")
    (version "0.6.3")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "tree-sitter" version))
        (file-name
          (string-append name "-" version ".tar.gz"))
        (sha256
          (base32
            "1c65218wdgybwmhnlliw29lgsmh6a3r6r0395nnpp9lxnqf1hvip"))))
    (build-system cargo-build-system)
    (arguments
      `(#:cargo-inputs
        (("rust-cc" ,rust-cc-1)
         ("rust-regex" ,rust-regex-1)
         ("rust-serde" ,rust-serde-1)
         ("rust-serde-derive" ,rust-serde-derive-1)
         ("rust-serde-json" ,rust-serde-json-1))))
    (home-page
      "https://github.com/tree-sitter/tree-sitter")
    (synopsis
      "Rust bindings to the Tree-sitter parsing library")
    (description
      "Rust bindings to the Tree-sitter parsing library")
    (license license:expat)))

(define-public kak-search-highlighter
  (package
    (name "kak-search-highlighter")
    (version "762054a222f68d748aa1f29fe2318309462e7b31")
    (source
      (origin
        (method git-fetch)
        (uri
          (git-reference
            (url "https://github.com/alexherbo2/search-highlighter.kak")
            (commit version)))
        (file-name (git-file-name name version))
        (sha256 (base32 "0ibrhv1yf2yly26q9rl89iig85c4zp2dxg4vm0frb0aqhswi03s2"))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       `(("rc" "share/kak/rc"))))
    (home-page "https://github.com/alexherbo2/search-highlighter.kak")
    (synopsis "Search highlighter for kakoune")
    (description "Search highlighter for kakoune.")
    (license license:unlicense)))

(define-public parinfer-rust
  (package
    (name "parinfer-rust")
    (version "0.4.3")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/eraserhd/parinfer-rust/archive/v"
                            version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "00fjyapvyi95g65iml0skppza0s1pigl3qvbkg319hy0m3mdhbvm"))
        (patches
          (search-patches "patches/parinfer-rust-new-emacs-version.patch"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
       (("rust-getopts" ,rust-getopts-0.2)
        ("rust-libc" ,rust-libc-0.2)
        ("rust-emacs" ,rust-emacs-0.16)
        ("rust-serde" ,rust-serde-1)
        ("rust-serde-json" ,rust-serde-json-1)
        ("rust-serde-derive" ,rust-serde-derive-1)
        ("rust-unicode-segmentation" ,rust-unicode-segmentation-1)
        ("rust-unicode-width" ,rust-unicode-width-0.1))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'install-kakoune-rc
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (out-rc (string-append out "/share/kak/rc")))
               (mkdir-p out-rc)
               (copy-file "rc/parinfer.kak" (string-append out-rc "/parinfer.kak")))
             #t)))))
    (native-inputs
     `(("pkg-config" ,pkg-config)))
    (inputs
     `(("clang" ,clang)))
    (home-page "https://github.com/eraserhd/parinfer-rust")
    (synopsis "A Rust port of parinfer")
    (description "Infer parentheses for Clojure, Lisp and Scheme.")
    (license license:isc)))

(define-public rust-emacs-0.16
  (package
    (name "rust-emacs")
    (version "0.16.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "emacs" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "1badqz4skmk6mq10mrsknxy22fbh71my1swrray4wzzfzf3y1bf6"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
       (("rust-anyhow" ,rust-anyhow-1)
        ("rust-ctor" ,rust-ctor-0.1)
        ("rust-emacs-macros" ,rust-emacs-macros-0.15)
        ("rust-emacs-module" ,rust-emacs-module-0.12)
        ("rust-once-cell" ,rust-once-cell-1)
        ("rust-thiserror" ,rust-thiserror-1)
        ("rust-rustc-version" ,rust-rustc-version-0.2))))
    (home-page "https://github.com/ubolonton/emacs-module-rs")
    (synopsis "Rust library for creating Emacs’s dynamic modules")
    (description "Rust library for creating Emacs’s dynamic modules")
    (license license:bsd-3)))

(define-public rust-emacs-macros-0.15
  (package
    (name "rust-emacs-macros")
    (version "0.15.1")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "emacs-macros" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "0xz4scnxrvssa5cb4avw0xyiphzl1ms03zjpxvyc1v0iy471cc8b"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
       (("rust-darling" ,rust-darling-0.10)
        ("rust-proc-macro2" ,rust-proc-macro2-1)
        ("rust-quote" ,rust-quote-1)
        ("rust-syn" ,rust-syn-1))))
    (home-page "https://github.com/ubolonton/emacs-module-rs")
    (synopsis "Rust library for creating Emacs’s dynamic modules")
    (description "Rust library for creating Emacs’s dynamic modules")
    (license license:bsd-3)))

(define-public rust-emacs-module-0.12
  (package
    (name "rust-emacs-module")
    (version "0.12.0")
    (source
      (origin
        (method url-fetch)
        (uri (crate-uri "emacs_module" version))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "0h57x1lppd93cbs3nix9z6yxwf3waipnmp53zd7sr5zb8pf2s6ks"))))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
       (("rust-bindgen" ,rust-bindgen-0.51))))
    (home-page "https://github.com/ubolonton/emacs-module-rs")
    (synopsis "Rust library for creating Emacs’s dynamic modules")
    (description "Rust library for creating Emacs’s dynamic modules")
    (license license:bsd-3)))
