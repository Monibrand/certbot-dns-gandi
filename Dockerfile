FROM certbot/certbot:arm32v6-v1.0.0

COPY ./challenge /challenge

RUN apk update && \
    apk add bash curl coreutils && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/challenge/run.sh"]
