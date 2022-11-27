#!/bin/bash
set -e
cd /tmp
mkdir -p backup/container1/d1 backup/container2/d2
echo "d1/f1" > backup/container1/d1/f1.txt
echo "d1/f2" > backup/container1/d1/f2.txt
echo "d2/f1" > backup/container2/d2/f1.txt
echo "d2/f2" > backup/container2/d2/f2.txt
tar cvzf --sort=name /tmp/local.tar.gz backup
md5sum /tmp/local.tar.gz
