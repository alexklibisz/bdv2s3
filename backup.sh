#!/bin/bash
set -e
/bin/sh /checkenv.sh
AWS_S3_KEY="$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz"
echo "Creating new backup with key [${AWS_S3_KEY}]"
tar cvf /tmp/backup.tar --sort=name backup
md5sum /tmp/backup.tar
gzip -n /tmp/backup.tar
md5sum /tmp/backup.tar.gz
aws s3 cp /tmp/backup.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_KEY
echo "Completed backup"
