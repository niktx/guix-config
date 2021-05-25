(define-module (n1ks home-services tmux)
  #:use-module (gnu services)
  #:use-module (gnu home-services files)
  #:use-module (guix gexp)
  #:export (home-tmux-service))

(define %tmux-config
  "set-option -g default-terminal \"tmux-256color\"
set-option -ga terminal-overrides \",*col*:Tc\"
set-window-option -g mode-keys vi
set-option -g mouse on
set-option -s escape-time 0
set-option -g status-right \"#{pane_title}\"")

(define home-tmux-service
  (simple-service
   'tmux-config home-files-service-type
   `(("tmux.conf" ,(plain-file "tmux-config" %tmux-config)))))
