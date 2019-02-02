FROM jackfirth/racket:7.0

WORKDIR /app

COPY . /app/

RUN raco pkg install --auto --link -j $(grep -c ^processor /proc/cpuinfo)

ENV SERVEIP_ADDRESS "::"
ENV SERVEIP_PORT "8080"
ENV SERVEIP_LOGFILE "-"

EXPOSE 8080

ENTRYPOINT ["/app/docker-entrypoint.sh"]
