#!/bin/sh
set -e
/bin/sh /checkenv.sh

cd /

AWS_S3_KEY="$AWS_S3_KEY_PREFIX$(date +%Y%m%d%H%M%S).tar.gz"
echo "Creating new backup with key [${AWS_S3_KEY}]"

echo "Stopping any containers with label bdv2s3.stop-during-backup=true"
CONTAINERS_TO_STOP=$(docker ps --format "{{.ID}}" --filter "label=bdv2s3.stop-during-backup=true")
for C in $CONTAINERS_TO_STOP
do
    echo "Stopping $C"
    docker stop $C
done

echo "Creating backup"
tar cvf backup.tar --sort=name ./backup
md5sum backup.tar
gzip -f -n backup.tar
md5sum backup.tar.gz

echo "Starting containers that were stopped"
for C in $CONTAINERS_TO_STOP
do
    echo "Starting $C"
    docker start $C
done

echo "Copying backup to S3"
aws s3 cp backup.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_KEY
rm backup.tar.gz

echo "Calling heartbeat URL"
curl -f $HEARTBEAT_URL

echo "All done"
