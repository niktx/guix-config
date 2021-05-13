(define-module (renameutils)
  #:use-module (gnu packages readline)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public renameutils
  (package
    (name "renameutils")
    (version "0.12.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://download.savannah.gnu.org/releases/renameutils/renameutils-"
                            version ".tar.gz"))
        (sha256
          (base32 "18xlkr56jdyajjihcmfqlyyanzyiqqlzbhrm6695mkvw081g1lnb"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-before 'install 'fix-makefile
           (lambda _
             (substitute* '("src/Makefile.am" "src/Makefile.in")
               (("\\(\\$bindir\\)")
                "$(bindir)"))
             #t)))))
    (inputs
     `(("readline" ,readline)))
    (synopsis "Utilities for renaming files")
    (description "The file renaming utilities (renameutils for short) are a set
of programs designed to make renaming of files faster and less cumbersome.")
    (home-page "https://www.nongnu.org/renameutils/")
    (license license:gpl2+)))
