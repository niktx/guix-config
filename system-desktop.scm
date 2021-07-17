(use-modules
  (gnu)
  (guix gexp)
  (nongnu packages linux)
  (nongnu system linux-initrd)
  (n1ks services logiops))
(use-package-modules gnome xorg)
(use-service-modules authentication desktop linux networking pm virtualization xorg)

(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "de"))
  (host-name "t14-guix")
  (groups
    (cons* (user-group
             (name "i2c")
             (system? #t))
           %base-groups))
  (users
    (cons* (user-account
             (name "niklas")
             (comment "Niklas Sauter")
             (group "users")
             (home-directory "/home/niklas")
             (supplementary-groups
              '("wheel" ;; Required to use sudo
                "netdev" ;; Required to manage network interfaces
                "audio" "video" ;; Required to access audio and video devices
                "kvm" "libvirt" ;; Required for virtual machines
                "i2c"))) ;; Required to control i2c devices
           %base-user-accounts))
  (packages
    (append
      (list (specification->package "nss-certs"))
      (list (specification->package "btrfs-progs"))
      %base-packages))
  (services
    (append
      (list (service gnome-desktop-service-type)
            (set-xorg-configuration
              (xorg-configuration
                (modules (delete xf86-input-synaptics %default-xorg-modules))
                (keyboard-layout keyboard-layout)))
            (service fprintd-service-type)
            (service bluetooth-service-type
              (bluetooth-configuration (auto-enable? #t)))
            (service logiops-service-type
              (logiops-configuration
                (config-file (local-file "data/logid.cfg"))))
            (service zram-device-service-type
              (zram-device-configuration (size "24G")))
            (service tlp-service-type)
            (service virtlog-service-type)
            (service libvirt-service-type
              (libvirt-configuration (unix-sock-group "libvirt")))
            (udev-rules-service 'assign-i2c-group
              (udev-rule
                "45-assign-i2c-group.rules"
                "KERNEL==\"i2c-[0-9]*\", GROUP=\"i2c\", MODE=\"0660\"")))
      (modify-services %desktop-services
        ;; Add openvpn plugin to network-manager
        (network-manager-service-type config =>
          (network-manager-configuration
            (inherit config)
            (vpn-plugins (list network-manager-openvpn))))
        ;; Add substitution server for nonguix channel
        (guix-service-type config =>
          (guix-configuration
            (inherit config)
            (substitute-urls
              (append (list "https://mirror.brielmaier.net")
                      %default-substitute-urls))
            (authorized-keys
              (append (list (local-file "data/mirror.brielmaier.net.pub"))
                      %default-authorized-guix-keys)))))))
  (bootloader
    (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (target "/boot/efi")
      (keyboard-layout keyboard-layout)))
  (file-systems
    (cons* (file-system
             (device (uuid "4F94-DE96" 'fat32))
             (mount-point "/boot/efi")
             (type "vfat"))
           (file-system
             (device (file-system-label "my-drive"))
             (mount-point "/")
             (type "btrfs")
             (options "subvol=@"))
           (file-system
             (device (file-system-label "my-drive"))
             (mount-point "/home")
             (type "btrfs")
             (options "subvol=@home"))
           %base-file-systems)))
