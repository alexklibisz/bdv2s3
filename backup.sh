#!/bin/sh
set -e
/bin/sh /checkenv.sh

AWS_S3_KEY="$AWS_S3_KEY_PREFIX$(date +%Y%m%d%H%M%S).tar.gz"
echo "Creating new backup with key [${AWS_S3_KEY}]"

echo "Stopping any containers with label bdv2s3.stop-during-backup=true"
for container in $(docker ps --format "{{.ID}}" --filter "label=bdv2s3.stop-during-backup=true")
do
    echo $container
done

tar cvf backup.tar --sort=name ./backup
md5sum backup.tar
gzip -f -n backup.tar
md5sum backup.tar.gz
aws s3 cp backup.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_KEY
rm backup.tar.gz
echo "Completed backup"
