FROM amazon/aws-cli:latest AS base

FROM base AS base-amd64
ENV SUPERCRONIC_SHA1SUM=71b0d58cc53f6bd72cf2f293e09e294b79c666d8
FROM base AS base-arm64
ENV SUPERCRONIC_SHA1SUM=e0f0c06ebc5627e43b25475711e694450489ab00
FROM base AS base-arm
ENV SUPERCRONIC_SHA1SUM=0d3e3da1eeceaa34991d44b48aecfcbb9d9fba5a

ARG TARGETARCH
FROM base-$TARGETARCH AS app

RUN yum -y update && \
  yum -y install systemd cronie tar gzip git gettext wget

ARG TARGETARCH
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-${TARGETARCH} \
  SUPERCRONIC=supercronic-linux-${TARGETARCH}
RUN wget "$SUPERCRONIC_URL" \
  && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
  && chmod +x "$SUPERCRONIC" \
  && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
  && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

WORKDIR /app

COPY crontab crontab
COPY entrypoint.sh entrypoint.sh

RUN touch /app/crontab.live
RUN chown -R 1001:1001 /app/crontab.live

RUN mkdir /app/locks
RUN chown -R 1001:1001 /app/locks

RUN chmod +x entrypoint.sh

USER 1001:1001

ENV SOURCE_DIR=/app/source

ENTRYPOINT ["sh", "entrypoint.sh"]

CMD ["/usr/local/bin/supercronic", "/app/crontab.live"]