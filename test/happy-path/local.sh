#!/bin/bash
set -e
cd /tmp
mkdir -p backup/d1 backup/d2
echo "d1/f1" > backup/d1/f1.txt
echo "d1/f2" > backup/d1/f2.txt
echo "d2/f1" > backup/d2/f1.txt
echo "d2/f2" > backup/d2/f2.txt
tar cvzf local.tar.gz backup
