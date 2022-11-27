#!/bin/sh
set -e
mkdir -p /data/d1
echo "d1/f1" > /data/d1/f1.txt
echo "d1/f2" > /data/d1/f2.txt
ls -la /data/d1
mkdir -p /data/d2
echo "d2/f1" > /data/d2/f1.txt
echo "d2/f2" > /data/d2/f2.txt
ls -la /data/d2
tail -f /dev/null
