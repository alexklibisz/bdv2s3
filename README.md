# bdv2s3

"backup docker volume to s3" — basically a simplified, opinionated version of [jareware/docker-volume-backup](https://github.com/jareware/docker-volume-backup).

## Usecase

I use this to backup docker-compose volumes in some self-hosted apps.

## Functionality

Run the bdv2s3 container as part of your docker-compose stack.
Mount the docker volumes that you want to backup in the `/backup` directory.
The container runs backups on the specified cron schedule, based on the `$BACKUP_CRON_EXPRESSION` environment variable.

When the cron triggers, the backup runs as follows:

1. Stops any containers with a label matching `$STOP_CONTAINERS_LABEL`.
1. Tars and gzips the `/backup` directory.
1. Encrypts the gzipped tar file using gpg and the `$ENCRYPTION_KEY` environment variable.
1. The final tarred, gzipped, encrypted file is called `$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz.gpg`.
1. Restarts the stopped containers.
1. Pushes the backup file to `s3://$AWS_S3_BUCKET/$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz.gpg`, using the `$AWS_S3_ACCESS_KEY_ID`, `$AWS_S3_ACCESS_KEY`, and `$AWS_S3_ENDPOINT_URL`.
1. curls the `$HEARTBEAT_URL` to indicate a successful backup.

### Usage with Backblaze B2

bdv2s3 is compatible with [Backblaze B2](https://www.backblaze.com/cloud-storage).
The environment variables should be specified as follows:

* `$AWS_ACCESS_KEY_ID` is the Backblaze application key ID.
* `$AWS_SECRET_ACCESS_KEY` is the Backblaze application key.
* `$AWS_S3_ENDPOINT_URL` is the bucket endpoint, e.g., `https://s3.us-west-002.backblazeb2.com`

The implementation is based solely on the official Backblaze [Quickstart Guide for AWS CLI and Backblaze B2 Cloud Storage](https://help.backblaze.com/hc/en-us/articles/360047779633-Quickstart-Guide-for-AWS-CLI-and-Backblaze-B2-Cloud-Storage).

## Example backup container

```yaml
version: '3.8'

# Define the volume.
volumes:
  my_volume:
    name: my_volume
    driver: local

services:
  some-service-with-a-volume:
    image: ...
    volumes:
      # Mount the volume in the container that actually uses it.
      - 'my_volume:/backup'
    labels:
      # Set this label here, and define it again as STOP_CONTAINERS_LABEL for the backup container.
      # The backup container will stop any other containers that have this label.
      # Note that any containers matching this key are going to be stopped, not just containers
      # in the local docker-compose stack.
      # So if the host is running multiple docker-compose stacks, make this label unique.
      - bdv2s3.some-arbitrary-key
  backup:
    # See https://github.com/alexklibisz/bdv2s3/pkgs/container/bdv2s3 for specific tags
    image: ghcr.io/alexklibisz/bdv2s3:latest
    volumes:
      # Mount the volume as read-only in the backup container.
      # All mounted volumes will be tarred, gzipped, encrypted into the same archive.
      - 'my_volume:/backup/my_volume:ro'

      # Mount the docker socket to let the backup container shutdown the service container.
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      # Cron schedule for running the backup.
      - BACKUP_CRON_EXPRESSION=0 8 * * *

      # Encryption key for encrypting the backup.
      # The backup is encrypted with gpg.
      - ENCRYPTION_KEY=***

      # Containers matching this label will be stopped during the backup.
      - STOP_CONTAINERS_LABEL=bdv2s3.some-arbitrary-key

      # The bucket where backups are stored.
      - AWS_S3_BUCKET=my-volume-backup-bucket

      # The prefix for each backup object in S3.
      # The suffix is the $(date +%Y%m%d%H%M%S).tar.gz.gpg.
      # e.g., my-volume-20221217164419.tar.gz.gpg
      - AWS_S3_KEY_PREFIX=my-volume-

      # Access key ID of the IAM user with PutObject permissions for this bucket.
      - AWS_ACCESS_KEY_ID=***

      # Access key of the IAM user with PutObject permissions for this bucket.
      - AWS_SECRET_ACCESS_KEY=***

      # URL passed to the AWS S3 CLI via aws s3 --endpoint-url=$AWS_S3_ENDPOINT_URL
      # This also lets us use Backblaze, e.g., https://s3.us-west-002.backblazeb2.com
      - AWS_S3_ENDPOINT_URL=https://s3.us-east-1.amazonaws.com

      # A heartbeat URL that is called after each successful backup, letting us monitor and alert on the backup.
      - HEARTBEAT_URL=https://heartbeat.uptimerobot.com/abcdefg
```

## Example restoring from backup

The restore process will generally look something like this:

Let's say the backup was stored at `s3://my-volume-backup-bucket/my-volume-20221217000000.tar.gz.gpg` and we want to restore it to the volume called `my_volume`.

```bash
# Download the backup from S3.
$ aws s3 cp s3://my-volume-backup-bucket/backup-20221217000000.tar.gz.gpg .
# Decrypt the backup (this will prompt for the passphrase).
$ gpg --batch --decrypt -o backup.tar.gz backup-20221217000000.tar.gz.gpg
# Untar the backup.
$ tar xzf backup.tar.gz
# Shut down the docker-compose stack (if it's currently running).
$ docker-compose down
# Delete the volume (if it's still around locally).
$ docker volume rm my_volume
# Re-create the volume.
$ docker volume create my_volume
# Run an rsync container with the backup directory and the volume mounted to restore the backup.
$ docker run --rm -v $PWD/backup/my_volume:/backup -v my_volume:/restore eeacms/rsync:2.4 rsync -az /backup/ /restore/
# Re-start the docker-compose stack.
$ docker-compose up
```

## End-to-end example

For an end-to-end example, see [test/postgres/docker-compose.yaml](./test/postgres/docker-compose.yaml) and the test-postgres job in [.github/workflows/ci.yaml](.github/workflows/ci.yaml).
