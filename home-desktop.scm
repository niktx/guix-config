(use-modules
  (gnu packages)
  (gnu home)
  (gnu home-services)
  (gnu home-services emacs)
  (gnu home-services ssh)
  (gnu home-services shells)
  (gnu home-services version-control)
  (n1ks home-services bash)
  (n1ks home-services emacs)
  (n1ks home-services git)
  (n1ks home-services legendary)
  (n1ks home-services xmodmap)
  (n1ks packages rust))

(define (specifications->package+output spec)
  (map (compose list specification->package+output)
       spec))

(define %packages
  (append
    ;; Programming
    (specifications->package+output
     '("gcc-toolchain"
       "ccls"
       "lldb"
       "rust"
       "rust:rustfmt"
       "rust:cargo"
       "rust-analyzer"))
    (list (list rust-src "out"))
    ;; Command line tools
    (specifications->package+output
     '("curl"
       "fd"
       "htop"
       "jq"
       "pwgen"
       "ripgrep"
       "rsync"
       "shellcheck"
       "tokei"
       "translate-shell"
       "trash-cli"
       "tree"
       "unzip"
       "wget"
       "xrandr"
       "xsel"
       "youtube-dl"
       "zip"))
    ;; Additional Gnome packages
    (specifications->package+output
     '("gnome-shell-extension-appindicator"
       "gnome-shell-extension-clipboard-indicator"
       "gnome-tweaks"))
    ;; Flatpak packages
    (specifications->package+output
     '("flatpak"
       "xdg-desktop-portal"
       "xdg-desktop-portal-gtk"))
    ;; Gaming packages
    (specifications->package+output
     '("dxvk"
       "wine64"))
    ;; Miscellaneous
    (specifications->package+output
     '("bluez"
       "celluloid"
       "evolution"
       "firefox"
       "font-iosevka"
       "geary"
       "gimp"
       "graphviz"
       "libreoffice"
       "man-pages"
       "pinentry"
       "restic"
       "seahorse"
       "virt-manager"
       "xdg-utils"))))

(home-environment
  (packages %packages)
  (services
   (list (service home-bash-service-type
                  %bash-configuration-desktop)
         (service home-ssh-service-type)
         (service home-git-service-type
                  %git-configuration-desktop)
         (service home-emacs-service-type
                  %emacs-configuration)
         (service home-legendary-service-type)
         (service home-xmodmap-service-type))))
