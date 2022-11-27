#!/bin/sh
set -e
sleep 3
tar cvf /out/expected.tar --sort=name backup
md5sum /out/expected.tar
gzip -n -f /out/expected.tar
md5sum /out/expected.tar.gz
tail -f /dev/null
