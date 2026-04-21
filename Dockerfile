FROM rclone/rclone:latest AS base

FROM base AS base-amd64
ENV SUPERCRONIC_SHA1SUM=b444932b81583b7860849f59fdb921217572ece2
FROM base AS base-arm64
ENV SUPERCRONIC_SHA1SUM=5193ea5292dda3ad949d0623e178e420c26bfad2
FROM base AS base-arm
ENV SUPERCRONIC_SHA1SUM=ef1c11d72eca0f5b63e237b93073c3b7986956a5

ARG TARGETARCH
FROM base-$TARGETARCH AS app

RUN apk add --no-cache gettext wget

ARG TARGETARCH
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.42/supercronic-linux-${TARGETARCH} \
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

RUN chmod +x entrypoint.sh

USER 1001:1001

ENV SOURCE_DIR=/app/source
ENV SYNC_CMD=move

ENTRYPOINT ["sh", "entrypoint.sh"]

CMD ["/usr/local/bin/supercronic", "/app/crontab.live"]
