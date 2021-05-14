(use-modules (gnu home)
             (gnu home-services)
             (gnu home-services files)
             (gnu home-services ssh)
             (gnu home-services shells)
             (gnu home-services version-control)
             (gnu packages)
             (gnu packages text-editors)
             (gnu services)
             (guix gexp)
             (kakoune-xyz))

(define %rust-packages
  '("rust"
    "rust:cargo"
    "rust-src"
    "rust-analyzer-bin"))

(define %devel-packages
  (append
   %rust-packages
   '("gcc-toolchain"
     "openssl")))

(define %kakoune-packages
  '("kakoune"
    "kak-lsp"
    "parinfer-rust"))

(define %packages
  (append
   %devel-packages
   %kakoune-packages
   '("bluez"
     "celluloid"
     "curl"
     "evolution"
     "fd"
     "firefox"
     "flatpak"
     "font-iosevka"
     "geary"
     "gimp"
     "git"
     "git:send-email"
     "github-cli"
     "gnome-shell-extension-appindicator"
     "gnome-shell-extension-clipboard-indicator"
     "gnome-tweaks"
     "graphviz"
     "htop"
     "jq"
     "libreoffice"
     "man-pages"
     "openssh"
     "pinentry"
     "pwgen"
     "renameutils"
     "restic"
     "ripgrep"
     "rsync"
     "seahorse"
     "shellcheck"
     "tig"
     "tmux"
     "tokei"
     "translate-shell"
     "trash-cli"
     "tree"
     "unzip"
     "virt-manager"
     "wget"
     "xdg-utils"
     "xrandr"
     "xsel"
     "youtube-dl"
     "zip")))

(define %bash-prompt
  '("source ~/.config/guix/data/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
prompt() {
    local status=\"$?\"
    local directory=\"\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\"
    local git=\"$(__git_ps1 ' \\[\\e[1;36m %s\\[\\e[0m\\]')\"
    if [ -n \"$GUIX_ENVIRONMENT\" ]; then
        local env=\" [env]\"
    fi
    if [ \"$status\" = \"0\" ]; then
        local indicator=\" \\[\\e[1;32m\\]$\\[\\e[0m\\]\"
    else
        local indicator=\" \\[\\e[1;31m\\]$\\[\\e[0m\\]\"
    fi
    PS1=\"${directory}${git}${env}${indicator} \"
}
PROMPT_COMMAND=prompt"))

(define %bash-aliases
  '("alias ls='ls -p --color=auto'"
    "alias grep='grep --color=auto'"
    "alias mv='mv --interactive'"
    "alias cp='cp --interactive'"
    "alias ln='ln --interactive'"
    "alias qmv='qmv --format=destination-only'"
    "alias qcp='qcp --format=destination-only'"
    "alias cfg='git --git-dir \"$HOME/.cfg\" --work-tree \"$HOME\"'"
    "alias cfg-tig='GIT_DIR=\"$HOME/.cfg\" GIT_WORK_TREE=\"$HOME\" tig'"))

(define %tmux-config
  "set-option -g default-terminal \"tmux-256color\"
set-option -ga terminal-overrides \",*col*:Tc\"
set-window-option -g mode-keys vi
set-option -g mouse on
set-option -s escape-time 0
set-option -g status-right \"#{pane_title}\"")

(define %tig-config
  "color cursor black green bold
color title-focus black blue bold
bind status P !git push origin")

(define %pijul-config
  "[author]
name = \"n1ks\"
full_name = \"Niklas Sauter\"
email = \"niklas@n1ks.net\"")

(define %xmodmap-config
  "keycode 110 = XF86AudioPrev
keycode 115 = XF86AudioPlay
keycode 118 = XF86AudioNext")

(define %xmodmap-script
  "#!/bin/sh
xmodmap ~/.Xmodmap")

(home-environment
  (home-directory (getenv "HOME"))
  (packages
   (map specification->package+output %packages))
  (services
   (list
    (service
      home-bash-service-type
      (home-bash-configuration
       (bash-profile
        '("export EDITOR=kak"
          "export VISUAL=kak"
          "export PAGER=\"less -R\""
          "export PATH=\"$HOME/.local/bin:$PATH\""
          "export PATH=\"$HOME/.cargo/bin:$PATH\""
          "export CC=gcc"
          "export RUST_SRC_PATH=\"$GUIX_HOME_ENVIRONMENT_DIRECTORY/lib/rustlib/src/rust/library\""
          "export OPENSSL_DIR=$(openssl version -d | sed 's/OPENSSLDIR: \"//' | sed 's/\"//' | sed 's;/share.*;;')"))
       (bashrc
        (append
         '("shopt -s histappend"
           "export HISTFILE=\"$XDG_CACHE_HOME/.bash_history\""
           "export HISTSIZE=100000"
           "export HISTFILESIZE=100000"
           "export HISTCONTROL=erasedups")
         %bash-prompt
         %bash-aliases))))
    (service
     home-git-service-type
     (home-git-configuration
      (config
       `((user
          ((name . "Niklas Sauter")
           (email . "niklas@n1ks.net")
           (signing-key . "F4047D8CF4CCCBD7F04CAC4446D2BA9AB7079F73")))
         (core
          ((ignore-case . #f)))
         (commit
          ((gpg-sign . #t)))
         (pull
          ((rebase . #f)))
         (status
          ((short . #t)))
         (log
          ((date . "format:%Y-%m-%d %H:%M:%S %z (%A)")))
         (alias
          ((a . "add")
           (c . "commit")
           (d . "diff")
           (l . "log")
           (g . "log --all --graph --decorate --oneline")
           (s . "status")))))))
    (service
     home-ssh-service-type
     (home-ssh-configuration
      (extra-config
       (list
        (ssh-host "vps"
                  `((user . "niklas")
                    (host-name "n1ks.net")))
        (ssh-host "pi"
                  `((user . "pi")
                    (host-name "raspberrypi")))))))
    (simple-service
     'tmux-config home-files-service-type
     `(("tmux.conf" ,(plain-file "tmux-config" %tmux-config))))
    (simple-service
     'kakoune-config home-files-service-type
     `(("config/kak/kakrc" ,(local-file "data/kakrc"))
       ("config/kak/kak-lsp.toml" ,(local-file "data/kak-lsp.toml"))
       ("config/kak/kak-tree.toml" ,(local-file "data/kak-tree.toml"))
       ("config/kak/autoload/plugins/core"
        ,(file-append kakoune "/share/kak/autoload"))
       ("config/kak/autoload/plugins/lsp"
        ,(file-append kak-lsp "/share/cargo/src/kak-lsp-9.0.0/rc"))
       ;; ("config/kak/autoload/plugins/tree"
       ;;  ,(file-append kak-tree "/share/kak/rc"))
       ("config/kak/autoload/plugins/parinfer"
        ,(file-append parinfer-rust "/share/kak/rc"))
       ("config/kak/autoload/plugins/search-highlighter"
        ,(file-append kak-search-highlighter "/share/kak/rc"))))
    (simple-service
     'tig-config home-files-service-type
     `(("config/tig/config" ,(plain-file "tig-config" %tig-config))))
    (simple-service
     'pijul-config home-files-service-type
     `(("config/pijul/config.toml" ,(plain-file "pijul-config" %pijul-config))))
    (simple-service
     'xmodmap-config home-files-service-type
     `(("Xmodmap" ,(plain-file "xmodmap-config" %xmodmap-config))
       ("xmodmap.sh" ,(plain-file "xmodmap-script" %xmodmap-script)))))))
