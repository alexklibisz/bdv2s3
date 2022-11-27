import boto3
import os
import requests
import tarfile
import time

assert 'AWS_ACCESS_KEY_ID' in os.environ, "Expected env var AWS_ACCESS_KEY_ID"
assert 'AWS_SECRET_ACCESS_KEY' in os.environ, "Expected env var AWS_SECRET_ACCESS_KEY"
assert 'AWS_DEFAULT_REGION' in os.environ, "Expected env var AWS_DEFAULT_REGION"
assert 'AWS_S3_BUCKET' in os.environ, "Expected env var AWS_S3_BUCKET"
assert 'AWS_S3_KEY_PREFIX' in os.environ, "Expected env var AWS_S3_KEY_PREFIX"
assert 'HEARTBEAT_URL' in os.environ, "Expected env var HEARTBEAT_URL"
assert 'INITIAL_SLEEP_SECONDS' in os.environ, "Expected env var INITIAL_SLEEP_SECONDS"
assert 'SLEEP_SECONDS' in os.environ, "Expected env var SLEEP_SECONDS"
assert os.path.exists('/backup') and os.path.isdir('/backup'), "Expected directory at /backup"

aws_s3_bucket = os.environ['AWS_S3_BUCKET']
aws_s3_key_prefix = os.environ['AWS_S3_KEY_PREFIX']
heartbeaat_url = os.environ['HEARTBEAT_URL']
initial_sleep_seconds = int(os.environ['INITIAL_SLEEP_SECONDS'])
sleep_seconds = int(os.environ['SLEEP_SECONDS'])

client = boto3.client('s3')

time.sleep(initial_sleep_seconds)
while True:
    aws_s3_key = f'{aws_s3_key_prefix}-{int(time.time())}.tar.gz'
    print(f"Creating new backup with key [{aws_s3_key}]")
    with tarfile.open('backup.tar.gz', "w:gz") as tar:
        tar.add('/backup', arcname='backup')
    with open('backup.tar.gz', 'rb') as tar:
        res = client.put_object(Body=tar, Bucket=aws_s3_bucket, Key=aws_s3_key)
    print(res)
    print(f"Completed new backup. Sleeping [{sleep_seconds}] seconds.")
    time.sleep(sleep_seconds)
