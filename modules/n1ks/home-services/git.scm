(define-module (n1ks home-services git)
  #:use-module (gnu home-services)
  #:use-module (gnu home-services version-control)
  #:export (home-git-service))

(define* (home-git-service #:key signing-key)
  (service home-git-service-type
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
           (s . "status"))))))))

