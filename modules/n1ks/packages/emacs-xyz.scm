(define-module (n1ks packages emacs-xyz)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:))

(define-public emacs-cargo-mode
  (let ((commit "078fb6e7e1da605b76a6d9a2f5d5acffd3be9c9f"))
    (package
     (name "emacs-cargo-mode")
     (version (git-version "0.0.0" "1" commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ayrat555/cargo-mode")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0xpyxx0qccpy26nrp3g6sm6d47w6b8824ib4ijkhhk2aj7waq2xx"))))
     (build-system emacs-build-system)
     (home-page "https://github.com/ayrat555/cargo-mode")
     (synopsis "Emacs minor mode which allows to dynamically select cargo
command")
     (description "Emacs minor mode which allows to dynamically select cargo
command.")
     (license license:expat))))
