(define-module (n1ks home-services git)
  #:use-module (gnu home-services)
  #:use-module (gnu home-services version-control)
  #:export (%git-configuration-desktop
            %git-configuration-server))

(define* (git-configuration #:key signing-key)
  (home-git-configuration
   (config
    `((user
       ((name . "Niklas Sauter")
        (email . "niklas@n1ks.net")
        ,@(if signing-key
              `((signing-key . ,signing-key))
              '())))
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
        (s . "status")))
      (github
       ((user . "nn1ks")))))))

(define %git-configuration-desktop
  (git-configuration #:signing-key "F4047D8CF4CCCBD7F04CAC4446D2BA9AB7079F73"))

(define %git-configuration-server
  (git-configuration #:signing-key #f))
