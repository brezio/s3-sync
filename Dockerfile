FROM amazon/aws-cli:latest

RUN yum -y update && \
  yum -y install systemd cronie tar gzip git gettext && \
  systemctl enable crond.service

WORKDIR /app

COPY s3-sync.cron.tmpl .
COPY entrypoint.sh .
COPY sync.sh .

RUN chmod +x ./entrypoint.sh
RUN chmod +x ./sync.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["crond", "-n"]