FROM amazon/aws-cli:latest

RUN yum -y update && \
  yum -y install systemd cronie tar gzip git gettext && \
  systemctl enable crond.service

WORKDIR /app

RUN addgroup --system --gid 1001 s3-sync
RUN adduser --system --uid 1001 s3-sync

COPY --chown=s3-sync:s3-sync s3-sync.cron.tmpl .
COPY --chown=s3-sync:s3-sync entrypoint.sh .
COPY --chown=s3-sync:s3-sync sync.sh .

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./sync.sh

USER s3-sync:s3-sync

ENTRYPOINT ["./entrypoint.sh"]
CMD ["crond", "-n"]