#!/bin/sh
set -e

# Set a default schedule, if the user didn't provide one
if [ -z "$CRON_SCHEDULE" ]; then
  export CRON_SCHEDULE='*/2 * * * *'
fi


if [ -z "$SYNC_OPTIONS" ]; then
  export SYNC_OPTIONS='--no-progress'
fi

echo "Updating cron schedule to $CRON_SCHEDULE"

# Run substitutions on the template file
envsubst < /app/crontab > /app/crontab.live

# Run the main container command
exec "$@"