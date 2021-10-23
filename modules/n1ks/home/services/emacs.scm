(define-module (n1ks home services emacs)
  #:use-module (guix gexp)
  #:use-module (flat packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu home services utils)
  ;; #:use-module (gnu home services emacs)
  #:use-module (n1ks home services emacs-upstream)
  #:use-module (n1ks packages emacs-xyz)
  #:export (%emacs-configuration))

(define %init-el
  `((add-to-list 'load-path ,(string-append
                              (getenv "HOME") "/.guix-home"
                              "/profile/share/emacs/site-lisp"))
    (guix-emacs-autoload-packages)
    ,(slurp-file-gexp
      (local-file
       (string-append (getenv "HOME") "/.config/guix/data/init.el")))))

(define %packages
  (list emacs-use-package
        emacs-gruvbox-theme
        emacs-general
        emacs-modalka
        emacs-multiple-cursors
        emacs-undo-tree
        emacs-avy
        emacs-hl-todo
        emacs-helpful
        emacs-vertico
        emacs-orderless
        emacs-marginalia
        emacs-consult
        emacs-which-key
        emacs-magit
        emacs-magit-todos
        emacs-diff-hl
        emacs-company
        emacs-yasnippet
        emacs-markdown-mode
        ;; emacs-flycheck
        ;; emacs-consult-flycheck
        emacs-lsp-mode
        emacs-lsp-ui
        emacs-consult-lsp
        emacs-dap-mode
        emacs-rust-mode
        emacs-elpy-custom
        emacs-parinfer-mode
        emacs-geiser
        emacs-geiser-guile
        emacs-meson-mode
        emacs-guix
        emacs-org
        emacs-org-roam
        emacs-eshell-syntax-highlighting
        emacs-eshell-toggle
        emacs-webkit
        emacs-elfeed
        emacs-elfeed-protocol
        emacs-elpher))

(define %emacs-configuration
  (home-emacs-configuration
   (package emacs-pgtk-native-comp)
   (elisp-packages %packages)
   (init-el %init-el)))
