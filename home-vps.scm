(use-modules
  (gnu packages)
  (gnu home)
  (gnu home-services)
  (gnu home-services ssh)
  (gnu home-services shells)
  (gnu home-services version-control)
  (n1ks home-services bash)
  (n1ks home-services git))

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
     "trash-cli"
     "tree"
     "wget")))

(home-environment
  (home-directory (getenv "HOME"))
  (packages %packages)
  (services
   (list (service home-bash-service-type
                  %bash-configuration-server)
         (service home-ssh-service-type)
         (service home-git-service-type
                  %git-configuration-server))))
