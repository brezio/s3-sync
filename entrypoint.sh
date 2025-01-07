#!/bin/sh
set -e

echo "Starting cron..."

printenv | grep -v "no_proxy" >> /etc/environment

# Set a default schedule, if the user didn't provide one
if [ -z "$CRON_SCHEDULE" ]; then
  export CRON_SCHEDULE='*/2 * * * *'
fi

if [ -z "$SOURCE_DIR" ]; then
  export SOURCE_DIR='/source'
fi

# Run substitutions on the template file and inject the crontab
envsubst < /app/s3-sync.cron.tmpl | crontab

# Run the main container command
exec "$@"