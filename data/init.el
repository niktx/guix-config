(setq gc-cons-threshold (* 50 1000 1000))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %s seconds with %d garbage collections"
                     (emacs-init-time "%.2f")
                     gcs-done)))

;; (setq native-comp-async-report-warnings-errors nil)

(require 'package)
(setq package-native-compilation t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(require 'use-package)

;; Set the theme
(load-theme 'gruvbox-dark-medium t)

;; Use the gnome keyring for credentials
(use-package auth-source
  :defer t
  :config
  (setq auth-sources "secrets:Default keyring"))

;; Disable some stuff
(setq inhibit-startup-screen t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(setq visible-bell t)

;; Set window title
;; (setq frame-title-format
;;       (list "%b"
;;             (let ((val (file-remote-p default-directory 'host)))
;;                  (if val (concat "@" val) nil))
;;             " \u2014 Emacs"))

;; Backup settings
(setq backup-directory-alist '(("." . "~/.cache/emacs/backups")))
(setq backup-by-copying t)
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
(setq version-control t)

;; Auto-save settings
(make-directory "~/.cache/emacs/auto-saves" t)
(setq auto-save-file-name-transforms '((".*" "~/.cache/emacs/auto-saves" t)))
(setq auto-save-list-file-prefix "~/.cache/emacs/auto-save-list/.saves-")

;; Save history
(savehist-mode 1)

;; Tab settings
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; Highlight matching parenthesis
(show-paren-mode 1)
;; Automatically insert closing parenthesis, quotes, etc.
(electric-pair-mode 1)

;; Line numbers
(use-package display-line-numbers
  :config
  (setq display-line-numbers-type 'relative)
  (defcustom display-line-numbers-exempt-modes
    '(shell-mode
      eshell-mode
      ;; lsp-ui-imenu-mode
      elfeed-search-mode
      elfeed-show-mode
      mu4e-headers-mode
      mu4e-view-mode)
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
  (global-display-line-numbers-mode))

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
  (async-shell-command "guix home reconfigure ~/.config/guix/home-desktop.scm"))

(defun guix-reconfigure-system ()
  "Run `guix system reconfigure'."
  (interactive)
  (async-shell-command
    (concat "echo " (shell-quote-argument (read-passwd "Password: "))
            " | sudo -ES guix system reconfigure ~/.config/guix/system-desktop.scm")))

(require 'general)
(general-define-key
  "C-j" 'scroll-up-command
  "C-k" 'scroll-down-command)
(general-define-key
  :keymaps '(org-mode-map latex-mode-map)
  "C-j" 'scroll-up-command)

(define-prefix-command 'my/window-map)
(global-set-key (kbd "C-w") 'my/window-map)
(global-set-key (kbd "\u00e4") 'my/window-map)
(general-define-key
  :keymaps '(my/window-map)
  "h" 'windmove-left
  "j" 'windmove-down
  "k" 'windmove-up
  "l" 'windmove-right
  "q" 'delete-window
  "v" 'split-window-horizontally
  "s" 'split-window-vertically)

(define-prefix-command 'my/custom-map)
(global-set-key (kbd "C-SPC") 'my/custom-map)
(global-set-key (kbd "\u00fc") 'my/custom-map)
(define-prefix-command 'my/guix-map)
(global-set-key (kbd "C-SPC x") 'my/guix-map)
(general-define-key
  :keymaps '(my/custom-map)
  ;; "b" 'counsel-ibuffer
  ;; "f" 'counsel-find-file
  ;; "b" 'switch-to-buffer
  "f" 'find-file
  "e" 'eshell
  "x c" 'guix-reconfigure-home
  "x C" 'guix-reconfigure-system)

(general-define-key
  :prefix "C-x"
  ;; "e" 'eshell
  "k" 'kill-current-buffer
  "K" 'kill-buffer
  "w" 'kill-buffer-and-window
  "s" 'save-buffer
  "S" 'save-some-buffers)


(defun my/downcase ()
  (interactive)
  (if (use-region-p)
      (downcase-region (region-beginning) (region-end))
      (downcase-region (point) (1+ (point)))))
(defun my/upcase ()
  (interactive)
  (if (use-region-p)
      (upcase-region (region-beginning) (region-end))
      (upcase-region (point) (1+ (point)))))

(defun mykbd/a ()
  (interactive)
  (forward-char)
  (modalka-mode -1))
(defun mykbd/b (count)
  (interactive "p")
  (set-mark (point))
  (backward-word count))
(defun mykbd/B (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (backward-word count))
(defun mykbd/c (count)
  (interactive "p")
  (mykbd/d count)
  (modalka-mode -1))
(defun mykbd/d (count)
  (interactive "p")
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
      (delete-char count t)))
(defun mykbd/f (count char)
  (interactive "p\ncSelect to char: ")
  (set-mark (point))
  (forward-char)
  (unwind-protect
    (search-forward (char-to-string char) nil nil count)))
(defun mykbd/F (count char)
  (interactive "p\ncSelect to char: ")
  (unless (use-region-p) (set-mark (point)))
  (forward-char)
  (unwind-protect
    (search-forward (char-to-string char) nil nil count)))
(defun mykbd/M-f (count char)
  (interactive "p\ncSelect to char: ")
  (set-mark (point))
  (unwind-protect
    (search-backward (char-to-string char) nil nil count)))
(defun mykbd/M-F (count char)
  (interactive "p\ncSelect to char: ")
  (unless (use-region-p) (set-mark (point)))
  (unwind-protect
    (search-backward (char-to-string char) nil nil count)))
(defun mykbd/h (count)
  (interactive "p")
  (deactivate-mark)
  (backward-char count))
(defun mykbd/H (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (backward-char count))
(defun mykbd/M-h (count)
  (interactive "p")
  (set-mark (point))
  (beginning-of-line))
(defun mykbd/j (count)
  (interactive "p")
  (deactivate-mark)
  (next-line count))
(defun mykbd/J (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (next-line count))
(defun mykbd/k (count)
  (interactive "p")
  (deactivate-mark)
  (previous-line count))
(defun mykbd/K (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (previous-line count))
(defun mykbd/l (count)
  (interactive "p")
  (deactivate-mark)
  (forward-char count))
(defun mykbd/L (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (forward-char count))
(defun mykbd/M-l (count)
  (interactive "p")
  (set-mark (point))
  (end-of-line))
(defun mykbd/o (count)
  (interactive "p")
  (end-of-line)
  (dotimes (_ count)
    (electric-newline-and-maybe-indent))
  (modalka-mode -1))
(defun mykbd/O (count)
  (interactive "p")
  (beginning-of-line)
  (dotimes (_ count)
    (newline)
    (forward-line -1))
  (modalka-mode -1))
(defun mykbd/M-o (count)
  (interactive "p")
  (end-of-line)
  (dotimes (_ count)
    (electric-newline-and-maybe-indent)))
(defun mykbd/M-O (count)
  (interactive "p")
  (beginning-of-line)
  (dotimes (_ count)
    (newline)
    (forward-line -1)))
(defun mykbd/p (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (yank))))
(defun mykbd/r (char)
  (interactive "cReplace with char: ")
  (mc/execute-command-for-all-cursors
    (lambda ()
      (interactive)
      (if (use-region-p)
          (progn (let ((region-size (- (region-end) (region-beginning))))
                   (delete-region (region-beginning) (region-end))
                   (mc/save-excursion
                     (insert-char char region-size t))))
          (progn (delete-region (point) (1+ (point)))
                 (mc/save-excursion)
                 (insert-char char))))))
(defun mykbd/t (count char)
  (interactive "p\ncSelect up to char: ")
  (set-mark (point))
  (forward-char)
  (unwind-protect
    (search-forward (char-to-string char) nil nil count)
    (backward-char)))
(defun mykbd/T (count char)
  (interactive "p\ncSelect up to char: ")
  (unless (use-region-p) (set-mark (point)))
  (forward-char)
  (unwind-protect
    (search-forward (char-to-string char) nil nil count)
    (backward-char)))
(defun mykbd/M-t (count char)
  (interactive "p\ncSelect up to char: ")
  (set-mark (point))
  (unwind-protect
    (search-backward (char-to-string char) nil nil count)
    (forward-char)))
(defun mykbd/M-T (count char)
  (interactive "p\ncSelect up to char: ")
  (unless (use-region-p) (set-mark (point)))
  (unwind-protect
    (search-backward (char-to-string char) nil nil count)
    (forward-char)))
(defun mykbd/w (count)
  (interactive "p")
  (set-mark (point))
  (forward-word count))
(defun mykbd/W (count)
  (interactive "p")
  (unless (use-region-p) (set-mark (point)))
  (forward-word count))
(defun mykbd/x (count)
  (interactive "p")
  (beginning-of-line)
  (set-mark (point))
  (forward-line count))
(defun mykbd/X (count)
  (interactive "p")
  (beginning-of-line)
  (unless (use-region-p) (set-mark (point)))
  (forward-line count))

(require 'modalka)
(setq modalka-cursor-type 'box)
(setq-default cursor-type 'bar)
(global-set-key (kbd "\u00F6") #'modalka-mode)
(add-hook 'prog-mode-hook #'modalka-mode)
(add-hook 'text-mode-hook #'modalka-mode)
(general-define-key
  :keymaps '(modalka-mode-map)
  "0" "C-0"
  "1" "C-1"
  "2" "C-2"
  "3" "C-3"
  "4" "C-4"
  "5" "C-5"
  "6" "C-6"
  "7" "C-7"
  "8" "C-8"
  "9" "C-9"
  "a" 'mykbd/a
  "b" 'mykbd/b
  "B" 'mykbd/B
  "c" 'mykbd/c
  "C" 'mc/mark-next-lines
  "M-C" 'mc/mark-previous-lines
  "d" 'mykbd/d
  "f" 'mykbd/f
  "F" 'mykbd/F
  "M-f" 'mykbd/M-f
  "M-F" 'mykbd/M-F
  "g h" 'beginning-of-line
  "g j" 'end-of-buffer
  "g l" 'end-of-line
  "g k" 'beginning-of-buffer
  "h" 'mykbd/h
  "H" 'mykbd/H
  "M-h" 'mykbd/M-h
  "i" 'modalka-mode
  "j" 'mykbd/j
  "J" 'mykbd/J
  "k" 'mykbd/k
  "K" 'mykbd/K
  "l" 'mykbd/l
  "L" 'mykbd/L
  "M-l" 'mykbd/M-l
  "o" 'mykbd/o
  "O" 'mykbd/O
  "M-o" 'mykbd/M-o
  "M-O" 'mykbd/M-O
  "p" 'mykbd/p
  "r" 'mykbd/r
  "s" 'mc/mark-all-in-region
  "t" 'mykbd/t
  "T" 'mykbd/T
  "M-t" 'mykbd/M-t
  "M-T" 'mykbd/M-T
  "w" 'mykbd/w
  "W" 'mykbd/W
  "x" 'mykbd/x
  "X" 'mykbd/X
  "y" 'kill-ring-save
  "%" 'mark-whole-buffer
  "^" 'my/upcase
  "°" 'my/downcase
  "SPC c" 'comment-line
  "SPC s" 'save-buffer
  "SPC w" 'my/window-map
  "SPC b" 'consult-buffer
  "SPC f" 'find-file
  "SPC e" 'eshell
  "SPC x c" 'guix-reconfigure-home
  "SPC x C" 'guix-reconfigure-system)
(eldoc-add-command 'mykbd/h 'mykbd/j 'mykbd/k 'mykbd/l)

(use-package undo-tree
  :bind (:map modalka-mode-map
         ("u" . undo-tree-undo)
         ("U" . undo-tree-redo)
         ("SPC u" . undo-tree-visualize)
         :map undo-tree-visualizer-mode-map
         ("h" . undo-tree-visualize-switch-branch-left)
         ("j" . undo-tree-visualize-redo)
         ("k" . undo-tree-visualize-undo)
         ("l" . undo-tree-visualize-switch-branch-right))
  :config
  (setq undo-tree-auto-save-history nil)
  (global-undo-tree-mode))

(use-package avy
  :bind (:map modalka-mode-map
         ("n" . mykbd/n)
         ("N" . mykbd/N))
  :config
  (defun mykbd/n (char)
    (interactive "cchar: ")
    (set-mark (point))
    (avy-goto-char char))
  (defun mykbd/N (count char)
    (interactive "p\ncchar: ")
    (unless (use-region-p) (set-mark (point)))
    (avy-goto-char char)))

(use-package hl-todo
  :config
  (global-hl-todo-mode))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h F" . helpful-function)
         ("C-h C" . helpful-command)
         :map helpful-mode-map
         ("j" . next-line)
         ("k" . previous-line)))

(use-package project
  :bind (:map my/custom-map
         ("p !" . project-shell-command)
         ("p &" . project-async-shell-command)
         ;; ("p b" . project-switch-to-buffer)
         ("p c" . project-compile)
         ("p d" . project-dired)
         ("p e" . project-eshell)
         ("p f" . project-find-file)
         ;; ("p g" . project-find-regexp)
         ("p k" . project-kill-buffers)
         ("p p" . project-switch-project)))

(use-package vertico
  :demand t
  :bind (:map vertico-map
         ("C-j" . vertico-next)
         ("C-k" . vertico-previous)
         ("C-S-j" . vertico-next-group)
         ("C-S-k" . vertico-previous-group))
  :config
  (vertico-mode))

(use-package orderless
  :config
  (setq completion-styles '(orderless))
  (set-face-foreground 'orderless-match-face-0 "#fabd2f")
  (set-face-foreground 'orderless-match-face-1 "#d3869b")
  (set-face-foreground 'orderless-match-face-2 "#fe8019")
  (set-face-foreground 'orderless-match-face-3 "#fb4933"))
  ;; (setq completion-category-defaults nil)
  ;; (setq completion-category-overrides '((file (styles . (partial-completion)))))

(use-package marginalia
  :config
  (marginalia-mode))

(use-package consult
  :bind (("C-f" . consult-line)
         :map my/custom-map
         ("b" . consult-buffer)
         ("h" . consult-ripgrep)
         ("i" . consult-imenu))
  :config
  (defun my/project-root ()
    (when (project-current)
      (project-root (project-current))))
  (setq consult-project-root-function #'my/project-root))

(use-package which-key
  :config
  (setq which-key-idle-delay 0.4)
  (which-key-mode))

(use-package magit
  :bind (:map my/custom-map
         ("g" . magit)
         ("G" . magit-dispatch)
         :map magit-status-mode-map
         ("j" . magit-section-forward)
         ("k" . magit-section-backward)
         ("J" . magit-section-forward-sibling)
         ("K" . magit-section-backward-sibling)
         ("h" . magit-status-jump)
         :map magit-mode-map
         ("p" . magit-push)
         ("N" . magit-file-untrack)))

(use-package magit-todos
  :after magit
  :bind (:map magit-todos-section-map
         ("j" . magit-section-forward)
         ("k" . magit-section-backward)
         :map magit-todos-item-section-map
         ("j" . magit-section-forward)
         ("k" . magit-section-backward))
  :config
  (magit-todos-mode))

;; (use-package forge)

(use-package diff-hl
  :after magit
  :bind (:map modalka-mode-map
         ("g g" . diff-hunk-next)
         ("g M-g" . diff-hunk-prev))
  :hook ((magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode))

(use-package company
  :demand t
  :config
  (setq company-idle-delay 0)
  (setq company-selection-wrap-around t)
  (global-company-mode)
  (company-tng-configure-default))

(use-package yasnippet
  :demand t
  :hook (lsp-mode-hook . yas-minor-mode-on))

(use-package markdown-mode
  :demand t)
  ;; :defer t)

;; (use-package flycheck
;;   :bind (:map modalka-mode-map
;;          ("g e" . flycheck-next-error)
;;          ("g M-e" . flycheck-previous-error))
;;   :config
;;   (global-flycheck-mode))

;; (use-package consult-flycheck
;;   :after flycheck
;;   :bind (:map modalka-mode-map
;;          ("SPC d" . consult-flycheck)))

(use-package lsp-mode
  :after (company yasnippet markdown-mode)
  :bind (:map lsp-mode-map
         ("TAB" . company-indent-or-complete-common)
         :map modalka-mode-map
         ("SPC t" . lsp-format-buffer)
         ("SPC T" . lsp-format-region)
         ("SPC a" . lsp-execute-code-action)
         ("SPC r" . lsp-rename)
         ("SPC l r" . lsp-workspace-restart)
         ("g d" . lsp-find-definition)
         ("g D" . lsp-find-type-definition))
  :hook ((rust-mode-hook . lsp)
         (c-mode-hook . lsp)
         (c++-mode-hook . lsp))
  :config
  (setq lsp-modeline-code-actions-enable nil)
  (setq lsp-semantic-tokens-enable nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-auto-execute-action nil))

(use-package lsp-ui
  :after lsp-mode
  :bind (:map lsp-ui-peek-mode-map
         ("j" . lsp-ui-peek--select-next)
         ("k" . lsp-ui-peek--select-prev)
         ("C-j" . lsp-ui-peek--select-next-file)
         ("C-k" . lsp-ui-peek--select-prev-file)
         :map modalka-mode-map
         ("SPC l f" . lsp-ui-doc-focus-frame)
         ("SPC h" . lsp-ui-doc-glance)
         ("g r" . lsp-ui-peek-find-references)
         ("g i" . lsp-ui-peek-find-implementation))
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-border "#7c6f64")
  (setq lsp-ui-doc-position 'at-point)
  (set-face-background 'lsp-ui-doc-background "#3c3836"))

(use-package consult-lsp
  :after lsp-mode
  :bind (:map modalka-mode-map
         ("SPC l d" . consult-lsp-diagnostics)
         ("SPC l s" . consult-lsp-symbols)))

(use-package dap-mode
  :after lsp-mode
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1))

(use-package tree-sitter
  :ensure t
  :hook (tree-sitter-after-on-hook . tree-sitter-hl-mode)
  :config
  (global-tree-sitter-mode))
(use-package tree-sitter-langs
  :ensure t
  :after tree-sitter)

(use-package rust-mode)

(use-package elpy
  :config
  (setq elpy-rpc-python-command "python3")
  (setq python-shell-interpreter "python3")
  (elpy-enable))

;; (use-package parinfer
;;   :hook ((lisp-mode-hook . parinfer-mode)
;;          (emacs-lisp-mode-hook . parinfer-mode)
;;          (scheme-mode-hook . parinfer-mode)))

(use-package geiser
  :defer t)
(use-package geiser-guile
  :after geiser)

(use-package guix
  :defer t)

(use-package org
  :defer t)
(use-package org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  :config
  (setq org-roam-directory "~/Documents/Notes")
  ;; (setq org-roam-dailies-directory "journals/")
  ;; (setq org-roam-capture-templates
  ;;       '(("d" "default" plain
  ;;          #'org-roam-capture--get-point "%?"
  ;;          :file-name "pages/${slug}" :head "#+title: ${title}\n" :unnarrowed t)))
  (org-roam-db-autosync-enable))

(use-package eshell-syntax-highlighting
  :config
  (eshell-syntax-highlighting-global-mode 1))

(use-package eshell-toggle
  :bind (:map my/custom-map
         ("E" . eshell-toggle)))

(use-package tramp
  :config
  (setq tramp-default-method "ssh")
  (push "~/.guix-home/profile/bin" tramp-remote-path))

;; (require 'erc)
;; (setq erc-prompt-for-password nil) ;; Use auth-sources for password
;; (defun erc-tls-libera ()
;;   "Run ERC and connect to the Libera Chat IRC server via TLS."
;;   (interactive)
;;   (erc-tls :server "irc.libera.chat"
;;            :port 6697
;;            :nick "n1ks"))

(use-package webkit
  :bind (:map webkit-mode-map
         ("k" . webkit-scroll-down-line)
         ("j" . webkit-scroll-up-line)
         ("h" . webkit-scroll-backward)
         ("l" . webkit-scroll-forward)
         ("+" . webkit-zoom-in)
         ("-" . webkit-zoom-out)
         ;; ("n" . webkit-ace)
         ("n" . webkit-search-next)
         ("M-n" . webkit-search-previous)
         ("r" . webkit-reload)
         ("H" . webkit-back)
         ("L" . webkit-forward)
         ("g" . nil)
         ("g k" . webkit-scroll-top)
         ("g j" . webkit-scroll-bottom)
         ("y" . webkit-copy-selection)
         ("Y" . webkit-copy-url)
         :map my/custom-map
         ("w" . webkit)))

;; (require 'elfeed)
;; (general-define-key
;;   :keymaps '(elfeed-search-mode-map elfeed-show-mode-map)
;;   "j" 'next-line
;;   "k" 'previous-line)
;; (add-hook 'elfeed-show-mode-hook #'visual-line-mode)
;; (require 'elfeed-protocol)
;; (setq elfeed-feeds '(("fever+https://admin@feed.n1ks.net"
;;                       :api-url "https://feed.n1ks.net/fever/"
;;                       ;; :use-authinfo t))) ;; FIXME
;;                       :password (shell-command-to-string
;;                                  "secret-tool lookup miniflux-fever admin"))))
;; (elfeed-protocol-enable)

;; (require 'mu4e)
;; (setq mu4e-change-filenames-when-moving t)
;; (setq mu4e-maildir "~/Mail")
;; (setq mu4e-sent-folder "/main/Sent")
;; (setq mu4e-drafts-folder "/main/Drafts")
;; (setq mu4e-trash-folder "/main/Trash")
;; (setq user-mail-address "niklas@n1ks.net")

;; (require 'elpher)

(use-package dired
  :bind (:map dired-mode-map
         ("j" . dired-next-line)
         ("k" . dired-previous-line)))

(setq gc-cons-threshold (* 2 1000 1000))
