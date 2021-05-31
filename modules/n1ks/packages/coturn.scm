(define-module (n1ks packages coturn)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages tls)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public coturn
  (package
    (name "coturn")
    (version "4.5.2")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/coturn/coturn/archive/refs/tags/"
                            version ".tar.gz"))
        (file-name (string-append name "-" version ".tar.gz"))
        (sha256 (base32 "0i9px1i542g5bgm36plv2nhi9aw8kq6m22fzr30jhps5qajilbs6"))))
    (build-system gnu-build-system)
    (inputs
     `(("pkg-config" ,pkg-config)
       ("openssl" ,openssl)
       ("libevent" ,libevent-with-openssl)))
    (synopsis "coturn TURN server")
    (description "coturn TURN server.")
    (home-page "https://github.com/coturn/coturn")
    (license license:bsd-3)))

(define libevent-with-openssl
  (package
    (inherit libevent)
    (name "libevent-with-openssl")
    (inputs
      (append
        (package-inputs libevent)
        `(("openssl" ,openssl))))))
