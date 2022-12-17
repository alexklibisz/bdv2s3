# bdv2s3

"backup docker volume to s3"

Basically a simplified, opinionated version of https://github.com/jareware/docker-volume-backup.

## Reference

### Behavior

* Run the bdv2s3 container as part of your docker-compose stack. Mount the docker volumes that you want to to backup in the `/backup` directory.
* The container runs backups on the specified cron schedule, based on the `$BACKUP_CRON_EXPRESSION` environment variable.
* The backup runs as follows:
    * Stops any containers with the label `bdv2s3.stop-during-backup=true`
    * Tars the `/backup` directory.
    * Gzips the tar file.
    * Encrypts the gzipped tar file using the `$ENCRYPTION_KEY` environment variable.
    * The final tarred, gzipped, encrypted file is called `$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz.gpg`.
    * Restarts the stopped containers.
    * Pushes the backup file to `s3://$AWS_S3_BUCKET/$AWS_S3_KEY_PREFIX-$(date +%Y%m%d%H%M%S).tar.gz.gpg`, using the `$AWS_S3_ACCESS_KEY_ID`, `$AWS_S3_ACCESS_KEY`, and `$AWS_DEFAULT_REGION`.
    * curls the `$HEARTBEAT_URL` to indicate a successful backup.

### Example backup container

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
      # Set this to stop this container during backup.
      - bdv2s3.stop-during-backup=true
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

      # The bucket containing your backups.
      - AWS_S3_BUCKET=my-volume-backup-bucket

      # The prefix for each backup object.
      # The suffix is the $(date +%Y%m%d%H%M%S).tar.gz.gpg.
      # e.g., my-volume-20221217164419.tar.gz.gpg
      - AWS_S3_KEY_PREFIX=my-volume-

      # Access key ID of the IAM user with PutObject permissions for this bucket.
      - AWS_ACCESS_KEY_ID=***

      # Access key of the IAM user with PutObject permissions for this bucket.
      - AWS_SECRET_ACCESS_KEY=***

      # Region where the bucket is located.
      - AWS_DEFAULT_REGION=us-east-1

      # A heartbeat URL that is called after each successful backup, letting us monitor and alert on the backup.
      - HEARTBEAT_URL=https://heartbeat.uptimerobot.com/abcdefg

      # Encryption key for encrypting the backup.
      # The backup is encrypted with gpg.
      - ENCRYPTION_KEY=***
```

### End-to-end example, including restoring the backup

For an end-to-end example, see [test/postgres/docker-compose.yaml](./test/postgres/docker-compose.yaml) and the test-postgres job in [.github/workflows/ci.yaml](.github/workflows/ci.yaml).
