#!/bin/sh
set -e

mkdir -p backup/container1/d1
echo "container1/d1/f1" > backup/container1/d1/f1.txt
echo "container1/d1/f2" > backup/container1/d1/f2.txt

mkdir -p backup/container1/d2
echo "container1/d2/f1" > backup/container1/d2/f1.txt
echo "container1/d2/f2" > backup/container1/d2/f2.txt

mkdir -p backup/container2/d1
echo "container2/d1/f1" > backup/container2/d1/f1.txt
echo "container2/d1/f2" > backup/container2/d1/f2.txt

mkdir -p backup/container2/d2
echo "container2/d2/f1" > backup/container2/d2/f1.txt
echo "container2/d2/f2" > backup/container2/d2/f2.txt

tar cvf backup.tar --sort=name data
md5sum backup.tar
gzip -f -n backup.tar
md5sum backup.tar.gz
