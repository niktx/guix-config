(define-module (n1ks home-services emacs)
  #:use-module (guix gexp)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu home-services-utils)
  #:use-module (gnu home-services emacs)
  #:export (%emacs-configuration))

(define %init-el
  `((add-to-list 'load-path ,(string-append
                              (getenv "GUIX_HOME_DIRECTORY")
                              "/profile/share/emacs/site-lisp"))
    (guix-emacs-autoload-packages)
    ,(slurp-file-gexp
      (local-file
       (string-append (getenv "HOME") "/.config/guix/data/init.el")))))

(define %packages
  (list emacs-diminish
        emacs-general
        emacs-kakoune
        emacs-phi-search
        emacs-undo-tree
        emacs-ivy
        emacs-ivy-rich
        emacs-hydra
        emacs-ivy-hydra
        emacs-counsel
        emacs-projectile
        emacs-counsel-projectile
        emacs-which-key
        emacs-magit
        emacs-magit-todos
        emacs-forge
        emacs-git-gutter
        emacs-rust-mode
        emacs-ccls
        emacs-lsp-mode
        emacs-lsp-ui
        emacs-lsp-ivy
        emacs-flycheck
        emacs-company
        emacs-yasnippet
        emacs-parinfer-mode
        emacs-geiser
        emacs-geiser-guile
        emacs-guix
        emacs-eshell-syntax-highlighting
        emacs-gruvbox-theme
        emacs-hl-todo
        emacs-elpher))

(define %emacs-configuration
  (home-emacs-configuration
   (elisp-packages %packages)
   (init-el %init-el)))
