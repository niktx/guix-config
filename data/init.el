;; Set the theme
(load-theme 'gruvbox-dark-medium t)

;; Use the gnome keyring for credentials
(require 'auth-source)
(setq auth-sources '("secrets:Default keyring"))

;; Disable some stuff
(setq inhibit-startup-screen t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

;; Backup settings
(setq backup-directory-alist '(("." . "~/.cache/emacs/backups")))
(setq backup-by-copying t)
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
(setq version-control t)

;; Tab settings
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; Highlight matching parenthesis
(show-paren-mode 1)
;; Automatically insert closing parenthesis, quotes, etc.
(electric-pair-mode 1)

;; Line numbers
(require 'display-line-numbers)
(setq display-line-numbers-type 'relative)
(defcustom display-line-numbers-exempt-modes
  '(eshell-mode lsp-ui-imenu-mode-hook)
  "Major modes on which to disable line numbers."
  :group 'display-line-numbers
  :type 'list
  :version "green")
(defun display-line-numbers--turn-on ()
  "Turn on line numbers except for certain modes.
Exempt major modes are defined in `display-line-numbers-exempt-modes'."
  (unless (or (minibufferp)
              (member major-mode display-line-numbers-exempt-modes))
    (display-line-numbers-mode)))
(global-display-line-numbers-mode)


(require 'general)
(define-prefix-command 'window-map)
(general-define-key
  "C-j" 'scroll-up-command
  "C-k" 'scroll-down-command)

(global-set-key (kbd "C-w") 'window-map)
(general-define-key
  :prefix "C-w"
  "h" 'windmove-left
  "j" 'windmove-down
  "k" 'windmove-up
  "l" 'windmove-right
  "q" 'delete-window
  "v" 'split-window-horizontally
  "s" 'split-window-vertically)

(define-prefix-command 'custom-map)
(global-set-key (kbd "C-SPC") 'custom-map)
(general-define-key
  :prefix "C-SPC"
  "b" 'counsel-ibuffer
  "f" 'counsel-find-file)

(general-define-key
  :prefix "C-x"
  "e" 'eshell
  "s" 'save-buffer
  "S" 'save-some-buffers)


(require 'diminish)
(diminish 'auto-revert-mode)
(diminish 'eldoc-mode)

(require 'kakoune)
(kakoune-setup-keybinds)
(global-set-key (kbd "C-f") 'ryo-modal-mode)
(defun ryo-enter () "Enter normal mode." (interactive) (ryo-modal-mode 1))
(add-hook 'prog-mode-hook #'ryo-enter)
(defun kakoune-M-l (count)
  (interactive "p")
  (set-mark (point))
  (end-of-line))
(ryo-modal-keys
  ("M-l" kakoune-M-l)
  ("SPC" (("c" comment-line)))
  ("," set-mark-command)
  ("C" mc/mark-next-lines)
  ("M-C" mc/mark-previous-lines))

(require 'undo-tree)
(global-undo-tree-mode)
(diminish 'undo-tree-mode)
(ryo-modal-keys
  ("u" undo-tree-undo)
  ("U" undo-tree-redo)
  ("SPC u" undo-tree-visualize))
(general-define-key
  :keymaps 'undo-tree-visualizer-mode-map
  "h" 'undo-tree-visualize-switch-branch-left
  "j" 'undo-tree-visualize-redo
  "k" 'undo-tree-visualize-undo
  "l" 'undo-tree-visualize-switch-branch-right)

(require 'phi-search)
(global-set-key (kbd "C-s") 'phi-search)
(global-set-key (kbd "C-r") 'phi-search-backward)

(require 'ivy)
(ivy-mode 1)
(diminish 'ivy-mode)
(general-define-key
  :keymaps 'ivy-minibuffer-map
  "TAB" 'ivy-alt-done
  "C-j" 'ivy-next-line
  "C-k" 'ivy-previous-line)
(require 'ivy-rich)

(require 'hydra)
(ivy-rich-mode 1)
(require 'ivy-hydra)

(require 'counsel)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x b") 'counsel-ibuffer)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(ryo-modal-keys
  (":" counsel-M-x))

(require 'projectile)
(projectile-mode 1)
(diminish 'projectile-mode)
(setq projectile-project-search-path '("~/Programming"))
(require 'counsel-projectile)
(counsel-projectile-mode)
(general-define-key
  :prefix "C-SPC"
  "p" 'counsel-projectile-switch-project
  "F" 'counsel-projectile-find-file
  "g" 'counsel-projectile-grep)

(require 'which-key)
(which-key-mode)
(diminish 'which-key-mode)
(setq which-key-idle-delay 0.2)

(require 'magit)
(general-define-key
  :keymaps '(magit-status-mode-map
             magit-log-mode-map
             magit-diff-mode-map
             magit-staged-section-map)
  "j" 'magit-section-forward
  "k" 'magit-section-backward)
(require 'magit-todos)
(magit-todos-mode)
(general-define-key
  :keymaps '(magit-todos-section-map
             magit-todos-item-section-map)
  "j" 'magit-section-forward
  "k" 'magit-section-backward)

(require 'git-gutter)
(global-git-gutter-mode 1)
(diminish 'git-gutter-mode)
(custom-set-variables
 '(git-gutter:hide-gutter t))
(ryo-modal-keys
  ("g" (("g" git-gutter:next-hunk)
        ("M-g" git-gutter:previous-hunk))))

(require 'rust-mode)

(require 'ccls)

(require 'lsp-mode)
(add-hook 'rust-mode-hook #'lsp)
(add-hook 'c-mode-hook #'lsp)
(add-hook 'c++-mode-hook #'lsp)
(add-hook 'lsp-mode-hook #'lsp-headerline-breadcrumb-mode)
;; (setq lsp-keymap-prefix "SPC l") ;; FIXME
(setq lsp-modeline-code-actions-enable nil)
(setq lsp-enable-semantic-highlighting nil)

(require 'lsp-ui)
(setq lsp-ui-doc-enable nil)
(ryo-modal-keys
  (:mode 'lsp-ui-mode)
  ("SPC l h" lsp-ui-doc-glance))

(require 'lsp-ivy)
(ryo-modal-keys
  (:mode 'lsp-mode)
  ("SPC l s" lsp-ivy-workspace-symbol)
  ("SPC l S" lsp-ivy-global-workspace-symbol))

(require 'flycheck)
(global-flycheck-mode)
(diminish 'flycheck-mode)

(require 'company)
(global-company-mode)
(diminish 'company-mode)
;; TODO: Setup TAB to cycle through the completion items
(define-key lsp-mode-map (kbd "TAB") 'company-indent-or-complete-common)
;; (define-key company-active-map (kbd "TAB") 'company-complete-selection)
(setq company-minimum-prefix-length 1)
(setq company-idle-delay 0.0)

(require 'yasnippet)
(add-hook 'lsp-mode-hook #'yas-minor-mode-on)
(diminish 'yas-minor-mode)

(add-to-list 'load-path "/home/niklas/src/emacs-tree-sitter/core")
(add-to-list 'load-path "/home/niklas/src/emacs-tree-sitter/lisp")
(add-to-list 'load-path "/home/niklas/src/emacs-tree-sitter/langs")
(require 'tree-sitter)
(require 'tree-sitter-hl)
(require 'tree-sitter-langs)
(require 'tree-sitter-debug)
(require 'tree-sitter-query)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

(require 'parinfer)
(add-hook 'lisp-mode-hook #'parinfer-mode)
(add-hook 'emacs-lisp-mode-hook #'parinfer-mode)
(add-hook 'scheme-mode-hook #'parinfer-mode)

(require 'geiser)
(require 'geiser-guile)

(require 'guix)

(require 'eshell-syntax-highlighting)
(eshell-syntax-highlighting-global-mode 1)

(require 'hl-todo)
(global-hl-todo-mode)

(require 'erc)
(setq erc-prompt-for-password nil) ;; Use auth-sources for password
(global-set-key (kbd "C-x E") (lambda () (interactive)
                                (erc-tls :server "irc.libera.chat"
                                         :port 6697
                                         :nick "n1ks")))
