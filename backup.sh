#!/bin/sh
set -e
/bin/sh /checkenv.sh

cd /

AWS_S3_KEY="$AWS_S3_KEY_PREFIX$(date +%Y%m%d%H%M%S).tar.gz.gpg"
echo "Creating new backup with key [${AWS_S3_KEY}]"

echo "Stopping any containers with label ${STOP_CONTAINERS_LABEL}"
CONTAINERS_TO_STOP=$(docker ps --format "{{.ID}}" --filter "label=${STOP_CONTAINERS_LABEL}")
for C in $CONTAINERS_TO_STOP
do
    echo "Stopping container $C"
    docker stop $C
done

echo "Creating backup"
tar cvf backup.tar --sort=name ./backup
md5sum backup.tar
du -hs backup.tar

echo "Starting containers that were stopped"
for C in $CONTAINERS_TO_STOP
do
    echo "Starting $C"
    docker start $C
done

echo "Zipping and encrypting backup"
gzip -f -n backup.tar
md5sum backup.tar.gz
du -hs backup.tar.gz
gpg --batch --symmetric --cipher-algo aes256 --passphrase $ENCRYPTION_KEY -o backup.tar.gz.gpg backup.tar.gz
md5sum backup.tar.gz.gpg

echo "Copying backup to s3://$AWS_S3_BUCKET/$AWS_S3_KEY"
aws s3 cp backup.tar.gz.gpg s3://$AWS_S3_BUCKET/$AWS_S3_KEY
rm backup.tar.gz backup.tar.gz.gpg

echo "Calling heartbeat URL"
curl --fail --silent $HEARTBEAT_URL

echo "All done"
