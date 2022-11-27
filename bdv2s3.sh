#!/bin/bash
set -e

ENV_VAR_ERROR=0

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo "Must provide AWS_ACCESS_KEY_ID in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "Must provide AWS_SECRET_ACCESS_KEY in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$AWS_DEFAULT_REGION" ]]; then
    echo "Must provide AWS_DEFAULT_REGION in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$AWS_S3_BUCKET" ]]; then
    echo "Must provide AWS_S3_BUCKET in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$AWS_S3_KEY_PREFIX" ]]; then
    echo "Must provide AWS_S3_KEY_PREFIX in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$HEARTBEAT_URL" ]]; then
    echo "Must provide HEARTBEAT_URL in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$INITIAL_SLEEP_SECONDS" ]]; then
    echo "Must provide INITIAL_SLEEP_SECONDS in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ -z "$SLEEP_SECONDS" ]]; then
    echo "Must provide SLEEP_SECONDS in environment" 1>&2
    ENV_VAR_ERROR=1
fi
if [[ "$ENV_VAR_ERROR" == 1 ]]; then
    exit 1
fi

echo "Sleeping [$INITIAL_SLEEP_SECONDS] seconds before starting."
sleep $INITIAL_SLEEP_SECONDS

while true
do
    AWS_S3_KEY="$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz"
    echo "Creating new backup with key [${AWS_S3_KEY}]"
    tar cvzf /tmp/backup.tar.gz --sort=name backup
    md5sum /tmp/backup.tar.gz
    aws s3 cp /tmp/backup.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_KEY
    echo "Completed backup. Sleeping [$SLEEP_SECONDS] seconds before next backup."
    sleep $SLEEP_SECONDS
done
