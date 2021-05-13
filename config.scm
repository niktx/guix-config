(use-modules
  (gnu)
  (gnu packages gnome)
  (gnu packages xorg)
  (nongnu packages linux)
  (nongnu system linux-initrd))
(use-service-modules desktop linux networking pm virtualization xorg)

(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "de"))
  (host-name "t14-guix")
  (users (cons* (user-account
                  (name "niklas")
                  (comment "Niklas Sauter")
                  (group "users")
                  (home-directory "/home/niklas")
                  (supplementary-groups
                    '("wheel" "netdev" "audio" "video" "kvm" "libvirt")))
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
            (service bluetooth-service-type
              (bluetooth-configuration (auto-enable? #t)))
            (service zram-device-service-type
              (zram-device-configuration (size "24G")))
            (service tlp-service-type)
            (service virtlog-service-type)
            (service libvirt-service-type
              (libvirt-configuration (unix-sock-group "libvirt"))))
      (modify-services %desktop-services
        (network-manager-service-type config =>
          (network-manager-configuration
            (inherit config)
            (vpn-plugins (list network-manager-openvpn))))
        (guix-service-type config =>
          (guix-configuration
            (inherit config)
            (substitute-urls
              (append (list "https://mirror.brielmaier.net")
                      %default-substitute-urls))
            (authorized-keys
              (append (list (local-file "mirror.brielmaier.net.pub"))
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
