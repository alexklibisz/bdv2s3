#!/bin/sh
set -e
/bin/sh /checkenv.sh

echo "$BACKUP_CRON_EXPRESSION /bin/sh /backup.sh" >> /etc/crontabs/root
crond -l 2 -f > /dev/stdout 2> /dev/stderr &

echo "Container started. Running backups on the provided cron [$BACKUP_CRON_EXPRESSION]. Run /backup.sh to run the backup manually."
tail -f /dev/null
