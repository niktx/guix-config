(define-module (n1ks packages emacs-xyz)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages webkit)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:))

(define-public emacs-elpy-custom
  (package
    (inherit emacs-elpy)
    (arguments
      (substitute-keyword-arguments (package-arguments emacs-elpy)
        ((#:phases phases)
         `(modify-phases ,phases
            (delete 'check)))))))

(define-public emacs-consult-lsp
  (let ((commit "12989949cc21a1173206f688d56a1e798073a4c3")
        (revision "1"))
    (package
      (name "emacs-consult-lsp")
      (version (git-version "0.2" revision commit))
      (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/gagbo/consult-lsp")
                (commit commit)))
          (file-name (git-file-name name version))
          (sha256
            (base32
              "0g3bpi53x6gr9631kzidbv4596bvdbxlr8y84ln40iwx5j8w6s7p"))))
      (build-system emacs-build-system)
      (propagated-inputs
       `(("emacs-consult" ,emacs-consult)
         ("emacs-lsp-mode" ,emacs-lsp-mode)))
      (home-page "https://github.com/gagbo/consult-lsp")
      (synopsis "LSP-mode and consult.el helping each other")
      (description "Helm and Ivy users have extra commands that leverage
lsp-mode extra information, let’s try to mimic a few features of helm-lsp and
lsp-ivy in consult workflow.")
      (license license:expat))))

(define-public emacs-consult-flycheck
  (let ((commit "92b259e6a8ebe6439f67d3d7ffa44b7e64b76478")
        (revision "1"))
    (package
      (name "emacs-consult-flycheck")
      (version (git-version "0.8" revision commit))
      (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/minad/consult-flycheck")
                (commit commit)))
          (file-name (git-file-name name version))
          (sha256
            (base32
              "15lihfdjdp5ynmq0g8wkq8dhb2jdlvfcqbb2ap588igi5vax3glz"))))
      (build-system emacs-build-system)
      (propagated-inputs
       `(("emacs-consult" ,emacs-consult)))
      (home-page "https://github.com/minad/consult-flycheck")
      (synopsis "This package provides the consult-flycheck command, which
integrates Consult with Flycheck")
      (description "This package provides the consult-flycheck command, which
integrates Consult with Flycheck.")
      (license #f))))

(define-public emacs-webkit
  (let ((commit "96a4850676b74ffa55b52ff8e9824f7537df6a47")
        (revision "1"))
    (package
      (name "emacs-webkit")
      (version (git-version "0.0.0" revision commit))
      (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/akirakyle/emacs-webkit")
                (commit commit)))
          (file-name (git-file-name name version))
          (sha256
            (base32
              "0ifdngan6jhbz6p72igwvmz7lhmz7hl8ak5n7zjkvxmq05kxkc5a"))))
      (build-system emacs-build-system)
      (arguments
       `(#:emacs ,emacs-next-pgtk
         #:phases
         (modify-phases %standard-phases
           (add-after 'unpack 'fix-build
             (lambda _
               (delete-file "evil-collection-webkit.el")
               (substitute* "webkit.el"
                 (("^\\(org-link-set-parameters.*") ""))))
           (add-before 'build 'pre-build
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((out (assoc-ref outputs "out")))
                 (setenv "HOME" "/tmp")
                 (setenv "CC" "gcc")
                 (invoke "make")
                 (copy-file "hints.css" (string-append out "/share/emacs/site-lisp/hints.css"))
                 (copy-file "hints.js" (string-append out "/share/emacs/site-lisp/hints.js"))
                 (copy-file "webkit-module.so" (string-append out "/share/emacs/site-lisp/webkit-module.so"))
                 (mkdir (string-append out "/lib"))
                 (copy-file "webkit-module.so" (string-append out "/lib/webkit-module.so"))))))))
      (native-inputs
       `(("pkg-config" ,pkg-config)))
      (inputs
       `(("glib" ,glib)
         ("glib-networking" ,glib-networking)
         ("gsettings-desktop-schemas" ,gsettings-desktop-schemas)
         ("gtk+", gtk+)
         ("webkitgtk" ,webkitgtk)))
      (propagated-inputs
       `(("emacs-org" ,emacs-org)))
      (home-page "https://github.com/minad/consult-flycheck")
      (synopsis "An Emacs Dynamic Module for WebKit, aka a fully fledged browser
inside emacs")
      (description "An Emacs Dynamic Module for WebKit, aka a fully fledged
browser inside emacs.")
      (license license:gpl3))))
