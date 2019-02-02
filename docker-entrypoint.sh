#!/bin/sh
set -eu
racket -l serveip -- --log-file "$SERVEIP_LOGFILE" "$SERVEIP_ADDRESS" "$SERVEIP_PORT"
