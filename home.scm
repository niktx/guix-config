(use-modules
  (gnu packages)
  (gnu home)
  (gnu home-services)
  (gnu home-services ssh)
  (n1ks home-services bash)
  (n1ks home-services git)
  (n1ks home-services tmux)
  (n1ks home-services kakoune)
  (n1ks home-services tig)
  (n1ks home-services xmodmap)
  (n1ks packages rust-ext))

(define %data-path
  (string-append (getenv "HOME") "/.config/guix/data"))

(define %packages
  (append
    (list rust-src rust-analyzer-bin)
    (map (compose list specification->package+output)
     '("rust" "rust:cargo" "gcc-toolchain" "openssl"))
    (map (compose list specification->package+output)
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
       "gnome-shell-extension-appindicator"
       "gnome-shell-extension-clipboard-indicator"
       "gnome-tweaks"
       "graphviz"
       "htop"
       "jq"
       "libreoffice"
       "man-pages"
       "pinentry"
       "pwgen"
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
       "zip"))))

(home-environment
  (home-directory (getenv "HOME"))
  (packages %packages)
  (services
    (list (home-bash-service #:prompt-display-host? #f)
          (home-git-service #:signing-key "F4047D8CF4CCCBD7F04CAC4446D2BA9AB7079F73")
          (service home-ssh-service-type
            (home-ssh-configuration
              (extra-config
                (list (ssh-host "vps"
                                `((user . "niklas")
                                  (host-name . "n1ks.net")))
                      (ssh-host "pi"
                                `((user . "pi")
                                  (host-name . "raspberrypi")))))))
          home-tmux-service
          (home-kakoune-service #:data-path %data-path)
          home-tig-service
          home-xmodmap-service)))
