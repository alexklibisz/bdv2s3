#!/bin/bash
set -e
/bin/sh /checkenv.sh
echo "Container started. Run ./backup.sh to run the backup."
tail -f /dev/null
