(use-modules
  (gnu packages)
  (gnu home)
  (gnu home services)
  ;; (gnu home services emacs)
  (n1ks home services emacs-upstream)
  ;; (gnu home services ssh)
  (gnu home services shells)
  ;; (gnu home services version-control)
  (n1ks home services version-control-upstream)
  (n1ks home services bash)
  (n1ks home services emacs)
  (n1ks home services git)
  (n1ks home services legendary)
  (n1ks packages gstreamer)
  (n1ks packages rust))

(define (specifications->package+output spec)
  (map (compose list specification->package+output)
       spec))

(define %packages
  (append
    ;; Programming
    (specifications->package+output
     '(;; C/C++
       "gcc-toolchain"
       "ccls"
       "lldb"
       ;; Rust
       "rust"
       "rust:rustfmt"
       "rust:cargo"
       "rust-analyzer"
       ;; Python
       "python"
       "python-numpy"
       "python-matplotlib"
       "python-seaborn"
       "gtk+" "python-pygobject" ;; Required for matplotlib GTK backend
       "python-qtpy")) ;; Required for matplotlib QT backend
    (list (list rust-src "out"))
    ;; GTK development
    (specifications->package+output
     '("pkg-config"
       "glib"
       "glib:bin"
       "cairo"
       "graphene"
       "pango"
       "gtk"
       "gdk-pixbuf"
       "libadwaita"))
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
       "ddcutil"
       "evolution"
       "firefox-wayland"
       "font-iosevka"
       "geary"
       "gimp"
       "graphviz"
       "libreoffice"
       "openvpn"
       "pinentry"
       "restic"
       "seahorse"
       "virt-manager"
       "xdg-utils"))
    (list (list gstreamer-vaapi "out"))))

(home-environment
  (packages %packages)
  (services
   (list (service home-bash-service-type
                  %bash-configuration-desktop)
         ;; (service home-ssh-service-type)
         (service home-git-service-type
                  %git-configuration-desktop)
         (service home-emacs-service-type
                  %emacs-configuration)
         (service home-legendary-service-type))))
