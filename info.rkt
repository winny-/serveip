#lang info
(define collection "serveip")
(define version "0.0.1")
(define deps
  '("base"
    "db-lib"
    "web-server-lib"
    "dotenv"))
(define racket-launcher-names '("serveip"))
(define racket-launcher-libraries '("main.rkt"))
