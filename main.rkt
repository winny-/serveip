#lang racket

(require web-server/servlet)
(provide start-serveip)

(define (start-serveip req)
  ; Get around the edge-case that client-ip was actually `::ffff:192.168.1.1'
  ; when listening on special address `::'.
  (define client-ip (match (request-client-ip req)
                      [(pregexp #px"(?i::ffff:([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+))"
                                (list _ ipv4)) ipv4]
                      [a a]))
  (response/full 200
                 #"OK"
                 (current-seconds)
                 #"text/plain"
                 empty
                 (list
                  (string->bytes/utf-8
                   (string-append client-ip
                                  "\n")))))

(module+ main
  (require web-server/servlet-env
           dotenv)
  (define (get-configuration cli-default-parameter env-var default-value [after-proc identity])
    (after-proc (or (cli-default-parameter) (getenv env-var) default-value)))
  (void (with-handlers ([exn:fail:filesystem? identity])
    (dotenv-load!)))
  (define LOG-FILE (make-parameter #f))
  (define ADDRESS (make-parameter #f))
  (define PORT (make-parameter #f))
  (command-line
   #:once-each
   [("-l" "--log-file") log-file "Log to file <log-file>" (LOG-FILE log-file)]
   #:args ([address #f] [port #f])
   (ADDRESS address)
   (PORT port))
  (serve/servlet start-serveip
                 #:listen-ip (get-configuration ADDRESS "SERVEIP_ADDRESS" "127.0.0.1")
                 #:port (get-configuration PORT "SERVEIP_PORT" "8080"
                                           (λ (s) (match (string->number s)
                                                    [(? listen-port-number? n) n]
                                                    [_ (raise-user-error 'serveip "Invalid port number `~a'." s)])))
                 #:servlet-regexp #rx".*"
                 #:command-line? #t
                 #:banner? #t
                 #:connection-close? #t
                 #:log-file (get-configuration LOG-FILE "SERVEIP_LOGFILE" #f
                                               (match-lambda
                                                 ["-" (current-output-port)]
                                                 [a a]))))