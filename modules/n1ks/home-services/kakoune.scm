(define-module (n1ks home-services kakoune)
  #:use-module (gnu home-services)
  #:use-module (gnu home-services files)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages text-editors)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (n1ks packages kakoune-xyz)
  #:export (home-kakoune-service-type
            home-kakoune-configuration
            home-kakoune-configuration?
            home-kakoune-service))

(define-maybe/no-serialization file-like)

(define-configuration/no-serialization home-kakoune-plugin-configuration
  (package
   (package (configuration-missing-field 'home-kakoune-plugin-configuration 'package))
   "The plugin package.")
  (path
   (string "/share/kak/rc")
   "The relative path to the kakoune files.")
  (config-file
   (maybe-file-like 'disabled)
   "The optional configuration file."))

(define (home-kakoune-plugin-configuration-list? val)
  (and (list? val)
       (and-map home-kakoune-plugin-configuration? val)))

(define-configuration/no-serialization home-kakoune-configuration
  (kakoune
   (package kakoune)
   "The kakoune package.")
  (plugins
   (home-kakoune-plugin-configuration-list '())
   "List of plugins.")
  (kakrc
   (maybe-file-like 'disabled)
   "The configuration file."))

(define (add-kakoune-packages config)
  (list (home-kakoune-configuration-kakoune config)))

(define (add-kakoune-configuration config)
  (let ((plugins (home-kakoune-configuration-plugins config))
        (kakrc (home-kakoune-configuration-kakrc config)))
    `(("config/kak/autoload/plugins/core"
       ,(file-append kakoune "/share/kak/autoload"))
      ,@(map (lambda (x)
               (let ((package (home-kakoune-plugin-configuration-package x))
                     (path (home-kakoune-plugin-configuration-path x)))
                 (list (string-append "config/kak/autoload/plugins/" (package-name package))
                       (file-append package path))))
             plugins)
      ,@(if (eq? kakrc 'disabled)
            '()
            `(("config/kak/kakrc" ,kakrc))))))

(define home-kakoune-service-type
  (service-type
    (name 'home-kakoune)
    (description "Install and configure the Kakoune text editor.")
    (extensions
      (list (service-extension home-profile-service-type
                               add-kakoune-packages)
            (service-extension home-files-service-type
                               add-kakoune-configuration)))
    (default-value (home-kakoune-configuration))))

(define* (home-kakoune-service #:key data-path)
  (service home-kakoune-service-type
    (home-kakoune-configuration
      (plugins
        (list (home-kakoune-plugin-configuration
                (package kak-lsp)
                (path (string-append "/share/cargo/src/kak-lsp-"
                                     (package-version kak-lsp)
                                     "/rc"))
                (config-file (local-file (string-append data-path "/kak-lsp.toml"))))
              ;; (home-kakoune-plugin-configuration
              ;;   (package kak-tree)
              ;;   (config-file (local-file "data/kak-tree.toml")))
              (home-kakoune-plugin-configuration
                (package parinfer-rust))
              (home-kakoune-plugin-configuration
                (package kak-search-highlighter))))
      (kakrc (local-file (string-append data-path "/kakrc"))))))
