FROM certbot/certbot

COPY ./challenge /challenge

RUN apk update && \
    apk add bash curl coreutils && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/challenge/run.sh"]
