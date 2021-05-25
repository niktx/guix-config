(define-module (n1ks home-services bash)
  #:use-module (gnu home-services)
  #:use-module (gnu home-services shells)
  #:export (home-bash-service))

(define* (%bash-prompt #:key prompt-display-host?)
  `("source ~/.config/guix/data/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
prompt() {
    local status=\"$?\""
    ,@(if prompt-display-host?
          '("    local user=\"\\[\\e[1;35m\\]\\u\\[\\e[0m\\]\"
    local hostname=\"\\[\\e[1;35m\\]\\h\\[\\e[0m\\]\"")
          '())
    "    local directory=\"\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\"
    local git=\"$(__git_ps1 ' \\[\\e[1;36m %s\\[\\e[0m\\]')\"
    if [ -n \"$GUIX_ENVIRONMENT\" ]; then
        local env=\" [env]\"
    fi
    if [ \"$status\" = \"0\" ]; then
        local indicator=\" \\[\\e[1;32m\\]$\\[\\e[0m\\]\"
    else
        local indicator=\" \\[\\e[1;31m\\]$\\[\\e[0m\\]\"
    fi"
    ,@(if prompt-display-host?
          '("    PS1=\"${user}@${hostname}:${directory}${git}${env}${indicator} \"")
          '("    PS1=\"${directory}${git}${env}${indicator} \""))
    "}
PROMPT_COMMAND=prompt"))

(define %bash-aliases
  '("alias ls='ls -p --color=auto'"
    "alias grep='grep --color=auto'"
    "alias mv='mv --interactive'"
    "alias cp='cp --interactive'"
    "alias ln='ln --interactive'"
    "alias qmv='qmv --format=destination-only'"
    "alias qcp='qcp --format=destination-only'"))

(define* (home-bash-service #:key prompt-display-host?)
 (service home-bash-service-type
   (home-bash-configuration
    (bash-profile
     '("export EDITOR=kak"
       "export VISUAL=kak"
       "export PAGER=\"less -R\""
       "export PATH=\"$HOME/.local/bin:$PATH\""
       "export PATH=\"$HOME/.cargo/bin:$PATH\""
       "export GUIX_PACKAGE_PATH=\"$HOME/.config/guix/guix-package-path\""
       "export GUILE_LOAD_PATH=\"$HOME/src/rde:$GUILE_LOAD_PATH\""
       "export GUILE_LOAD_PATH=\"$HOME/.config/guix/modules:$GUILE_LOAD_PATH\""
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
      (%bash-prompt #:prompt-display-host? prompt-display-host?)
      %bash-aliases)))))
