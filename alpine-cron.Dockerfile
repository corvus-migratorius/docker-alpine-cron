## Based on: xordiv/docker-alpine-cron
FROM alpine:3.15.0

LABEL base.image="alpine:3.15.0"
LABEL maintainer="Alexander Gorelyshev"
LABEL maintainer.email="alexander.gorelyshev@pm.me"
LABEL description="Alpine-based Cron scheduler"

RUN apk update \
    && apk add --no-cache \
        bash \
        bzip2 \
        ca-certificates \
        dcron \
        rsync \
        wget

RUN mkdir -p /var/log/cron \
    && mkdir -m 0644 -p /var/spool/cron/crontabs \
    && touch /var/log/cron/cron.log \
    && mkdir -m 0644 -p /etc/cron.d

COPY /scripts/* /scripts/

ENTRYPOINT ["bash", "/scripts/docker-entrypoint.sh"]
CMD ["bash", "/scripts/docker-cmd.sh"]
