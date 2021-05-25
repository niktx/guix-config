(use-modules
  (gnu home)
  (gnu home-services ssh)
  (n1ks home-services bash)
  (n1ks home-services git)
  (n1ks home-services tmux)
  (n1ks home-services kakoune)
  (n1ks home-services tig))

(define %data-path
  (string-append (getenv "HOME") "/.config/guix/data"))

(define %packages
  (map (compose list specification->package+output)
   '("curl"
     "docker-compose"
     "fd"
     "htop"
     "jq"
     "pwgen"
     "ripgrep"
     "rsync"
     "tig"
     "tmux"
     "trash-cli"
     "tree"
     "wget")))

(home-environment
  (home-directory (getenv "HOME"))
  (packages %packages)
  (services
    (list (home-bash-service #:prompt-display-host? #t)
          (home-git-service #:signing-key #f)
          (service home-ssh-service-type)
          home-tmux-service
          (home-kakoune-service #:data-path %data-path)
          home-tig-service)))
