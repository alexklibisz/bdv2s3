#!/bin/bash
set -e

ERROR=0
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo "Must provide AWS_ACCESS_KEY_ID in environment" 1>&2
    ERROR=1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "Must provide AWS_SECRET_ACCESS_KEY in environment" 1>&2
    ERROR=1
fi
if [[ -z "$AWS_DEFAULT_REGION" ]]; then
    echo "Must provide AWS_DEFAULT_REGION in environment" 1>&2
    ERROR=1
fi
if [[ -z "$AWS_S3_BUCKET" ]]; then
    echo "Must provide AWS_S3_BUCKET in environment" 1>&2
    ERROR=1
fi
if [[ -z "$AWS_S3_KEY_PREFIX" ]]; then
    echo "Must provide AWS_S3_KEY_PREFIX in environment" 1>&2
    ERROR=1
fi
if [[ -z "$HEARTBEAT_URL" ]]; then
    echo "Must provide HEARTBEAT_URL in environment" 1>&2
    ERROR=1
fi
if [[ "$ERROR" == 1 ]]; then
    exit 1
fi

AWS_S3_KEY="$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz"
echo "Creating new backup with key [${AWS_S3_KEY}]"
tar cvf /tmp/backup.tar --sort=name backup
md5sum /tmp/backup.tar
gzip -n /tmp/backup.tar
md5sum /tmp/backup.tar.gz
aws s3 cp /tmp/backup.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_KEY
echo "Completed backup. Sleeping [$SLEEP_SECONDS] seconds before next backup."
sleep $SLEEP_SECONDS