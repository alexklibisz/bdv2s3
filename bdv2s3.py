import boto3
import os
import requests
import tarfile
import time

assert 'AWS_ACCESS_KEY_ID' in os.environ, "Expected env var AWS_ACCESS_KEY_ID"
assert 'AWS_SECRET_ACCESS_KEY' in os.environ, "Expected env var AWS_SECRET_ACCESS_KEY"
assert 'AWS_DEFAULT_REGION' in os.environ, "Expected env var AWS_DEFAULT_REGION"
assert 'AWS_S3_BUCKET' in os.environ, "Expected env var AWS_S3_BUCKET"
assert 'HEARTBEAT_URL' in os.environ, "Expected env var HEARTBEAT_URL"
assert 'INITIAL_SLEEP_SECONDS' in os.environ, "Expected env var INITIAL_SLEEP_SECONDS"
assert 'SLEEP_SECONDS' in os.environ, "Expected env var SLEEP_SECONDS"
assert 'FILENAME_PREFIX' in os.environ, "Expected env var FILENAME_PREFIX"
assert os.path.exists('/backup') and os.path.isdir('/backup'), "Expected directory at /backup"

aws_s3_bucket = os.environ['AWS_S3_BUCKET']
heartbeaat_url = os.environ['HEARTBEAT_URL']
filename_prefix = os.environ['FILENAME_PREFIX']
initial_sleep_seconds = int(os.environ['INITIAL_SLEEP_SECONDS'])
sleep_seconds = int(os.environ['SLEEP_SECONDS'])

client = boto3.client('s3')

time.sleep(initial_sleep_seconds)
while True:
    backup_tarfile = f'/tmp/{filename_prefix}-{int(time.time())}.tar.gz'
    print(f"Creating new backup at [{backup_tarfile}]")
    with tarfile.open(backup_tarfile, "w:gz") as tar:
        tar.add('/backup', arcname='backup')
    time.sleep(sleep_seconds)
