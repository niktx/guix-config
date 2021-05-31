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
(setq visible-bell t)

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
  '(shell-mode eshell-mode lsp-ui-imenu-mode elfeed-search-mode elfeed-show-mode)
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

;; Modeline
(setq column-number-mode t)
(defvar default-mode-line mode-line-format)
(setq-default mode-line-format
              '((:eval (cond ((string-match-p "\\*.*\\*" (buffer-name)) " ")
                             (buffer-read-only " \ue0a2 ") ;; 
                             ((buffer-modified-p) " \u25cf ") ;; ●
                             (t " \u25cb "))) ;; ○
                (:eval (propertize "%b" 'face 'bold))
                " %l:%c ("
                (:eval (propertize "%m" 'face 'italic))
                ")"
                (vc-mode vc-mode)))


(defun guix-reconfigure-home ()
  "Run `guix home reconfigure'."
  (interactive)
  (async-shell-command "guix home reconfigure ~/.config/guix/home.scm"))

(defun guix-reconfigure-system ()
  "Run `guix system reconfigure'."
  (interactive)
  (async-shell-command
    (concat "echo " (shell-quote-argument (read-passwd "Password: "))
            " | sudo -S guix system reconfigure ~/.config/guix/config.scm")))

(require 'general)
(general-define-key
  "C-j" 'scroll-up-command
  "C-k" 'scroll-down-command)

(define-prefix-command 'custom-window-map)
(global-set-key (kbd "C-w") 'custom-window-map)
(general-define-key
  :keymaps 'custom-window-map
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
  :keymaps 'custom-map
  "b" 'counsel-ibuffer
  "f" 'counsel-find-file
  "c" 'guix-reconfigure-home
  "C" 'guix-reconfigure-system)

(general-define-key
  :prefix "C-x"
  "e" 'eshell
  "k" 'kill-current-buffer
  "K" 'kill-buffer
  "w" 'kill-buffer-and-window
  "s" 'save-buffer
  "S" 'save-some-buffers)


(require 'kakoune)
(kakoune-setup-keybinds)
(global-set-key (kbd "\u00F6") #'ryo-modal-mode)
(setq ryo-modal-cursor-type 'bar)
(setq-default cursor-type 'box)
(defun ryo-enter () "Enter normal mode." (interactive) (ryo-modal-mode 1))
(add-hook 'prog-mode-hook #'ryo-enter)
(defun kakoune-M-l (count)
  (interactive "p")
  (end-of-line))
(defun kakoune-M-h (count)
  (interactive "p")
  (beginning-of-line))
(ryo-modal-keys
  ("M-l" kakoune-M-l :first '(kakoune-set-mark-here))
  ("M-h" kakoune-M-h :first '(kakoune-set-mark-here))
  ("SPC" (("c" comment-line)
          ("s" save-buffer)
          ("S" save-some-buffers)))
  ("," set-mark-command)
  ("C" mc/mark-next-lines)
  ("M-C" mc/mark-previous-lines))

(require 'undo-tree)
(global-undo-tree-mode)
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

(require 'hl-todo)
(global-hl-todo-mode)

(require 'ivy)
(ivy-mode 1)
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
(setq which-key-idle-delay 0.2)

(require 'magit)
(general-define-key
  :keymaps '(magit-status-mode-map
             magit-log-mode-map
             magit-diff-mode-map
             magit-staged-section-map)
  "j" 'magit-section-forward
  "k" 'magit-section-backward)
(define-key magit-mode-map (kbd "C-w") 'custom-window-map)
(require 'magit-todos)
(magit-todos-mode)
(general-define-key
  :keymaps '(magit-todos-section-map
             magit-todos-item-section-map)
  "j" 'magit-section-forward
  "k" 'magit-section-backward)

(require 'forge)

(require 'git-gutter)
(global-git-gutter-mode 1)
(custom-set-variables
 '(git-gutter:hide-gutter t))
(ryo-modal-keys
  ("g" (("g" git-gutter:next-hunk)
        ("M-g" git-gutter:previous-hunk))))

(require 'rust-mode)
(require 'cargo-mode)
(setq cargo-path-to-bin "cargo")
(setq compilation-scroll-output t)
(add-hook 'rust-mode-hook #'cargo-minor-mode)

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

(require 'company)
(global-company-mode)
;; TODO: Setup TAB to cycle through the completion items
(define-key lsp-mode-map (kbd "TAB") 'company-indent-or-complete-common)
;; (define-key company-active-map (kbd "TAB") 'company-complete-selection)
(setq company-minimum-prefix-length 1)
(setq company-idle-delay 0.0)

(require 'yasnippet)
(add-hook 'lsp-mode-hook #'yas-minor-mode-on)

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
(global-set-key (kbd "C-SPC x") 'guix)

(require 'org)
(require 'org-roam)
(setq org-roam-directory "~/Documents/notes")
(setq org-roam-dailies-directory "journals/")
(setq org-roam-capture-templates
      '(("d" "default" plain
         #'org-roam-capture--get-point "%?"
         :file-name "pages/${slug}" :head "#+title: ${title}\n" :unnarrowed t)))
(org-roam-mode)

(require 'markdown-mode)

(require 'eshell-syntax-highlighting)
(eshell-syntax-highlighting-global-mode 1)

(require 'eshell-toggle)
(global-set-key (kbd "C-x E") 'eshell-toggle)

(require 'erc)
(setq erc-prompt-for-password nil) ;; Use auth-sources for password
(defun erc-tls-libera ()
  "Run ERC and connect to the Libera Chat IRC server via TLS."
  (interactive)
  (erc-tls :server "irc.libera.chat"
           :port 6697
           :nick "n1ks"))

(require 'elfeed)
(general-define-key
  :keymaps '(elfeed-search-mode-map elfeed-show-mode-map)
  "j" 'next-line
  "k" 'previous-line)
(add-hook 'elfeed-show-mode-hook #'visual-line-mode)
(require 'elfeed-protocol)
(setq elfeed-feeds '(("fever+https://admin@feed.n1ks.net"
                      :api-url "https://feed.n1ks.net/fever/"
                      ;; :use-authinfo t))) ;; FIXME
                      :password (shell-command-to-string
                                 "secret-tool lookup miniflux-fever admin"))))
(elfeed-protocol-enable)

(require 'elpher)
