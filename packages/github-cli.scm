(define-module (github-cli)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public github-cli
  (package
    (name "github-cli")
    (version "1.9.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/cli/cli/releases/download/v"
                            version "/gh_" version "_linux_amd64.tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "1jw8i52gc06gj69zr1vjhzcnan9s9pn5y4km72d0p7lll9zbya9b"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
     `(#:install-plan
       `(("bin", "./")
         ("share", "./"))))
    (synopsis "GitHub’s official command line tool")
    (description "gh is GitHub on the command line. It brings pull requests,
issues, and other GitHub concepts to the terminal next to where you are already
working with git and your code.")
    (home-page "https://github.com/cli/cli")
    (license license:expat)))
