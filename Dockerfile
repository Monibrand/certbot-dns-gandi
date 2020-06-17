FROM alpine
  
COPY ./challenge /challenge

RUN apk update && \
    apk add bash certbot curl coreutils && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/challenge/run.sh"]
