(define-module (n1ks home services bash)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix gexp)
  #:export (%bash-configuration-desktop
            %bash-configuration-server))

(define* (prompt #:key display-host?)
  `("source ~/.config/guix/data/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
prompt() {
    local status=\"$?\""
    ,@(if display-host?
          '("    local user=\"\\[\\e[1;35m\\]\\u\\[\\e[0m\\]\"
    local hostname=\"\\[\\e[1;35m\\]\\h\\[\\e[0m\\]\"")
          '())
    "    local directory=\"\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\"
    local git=\"$(__git_ps1 ' \\[\\e[1;36m\\] %s\\[\\e[0m\\]')\"
    if [ -n \"$GUIX_ENVIRONMENT\" ]; then
        local env=\" [env]\"
    fi
    if [ \"$status\" = \"0\" ]; then
        local indicator=\" \\[\\e[1;32m\\]$\\[\\e[0m\\]\"
    else
        local indicator=\" \\[\\e[1;31m\\]$\\[\\e[0m\\]\"
    fi"
    ,@(if display-host?
          '("    PS1=\"${user}@${hostname}:${directory}${git}${env}${indicator} \"")
          '("    PS1=\"${directory}${git}${env}${indicator} \""))
    "}
PROMPT_COMMAND=prompt"))

(define %aliases
  '("alias ls='ls -p --color=auto'"
    "alias grep='grep --color=auto'"
    "alias mv='mv --interactive'"
    "alias cp='cp --interactive'"
    "alias ln='ln --interactive'"))

(define* (bash-configuration #:key prompt-display-host?)
  (home-bash-configuration
   (environment-variables
    '(("PATH" . "\"$HOME/.local/bin:$PATH\"")
      ("PATH" . "\"$HOME/.cargo/bin:$PATH\"")
      ("XDG_DATA_DIRS" . "\"$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS\"")
      ("GUIX_PACKAGE_PATH" . "\"$HOME/.config/guix/guix-package-path\"")
      ("GUILE_LOAD_PATH" . "\"$HOME/.config/guix/modules:$GUILE_LOAD_PATH\"")
      ("CC" . "gcc")))
   ;; FIXME
   ;;(bashrc
   ;; (append
   ;;  (prompt #:display-host? prompt-display-host?)
   ;;  %aliases))))
   (bashrc
    (let* ((content-list (append
                          (prompt #:display-host? prompt-display-host?)
                          %aliases))
           (content (string-join content-list "\n")))
      (list (plain-file "bashrc" content))))))

(define %bash-configuration-desktop
  (bash-configuration #:prompt-display-host? #f))

(define %bash-configuration-server
  (bash-configuration #:prompt-display-host? #t))
