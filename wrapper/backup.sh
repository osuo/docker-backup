#!/bin/sh

if [ $# -ne 2 ]; then
  echo "usage..."
  echo "$0 DVC TGZ"
  exit 1
fi

docker run --rm --volumes-from $1 -v $(pwd):/backup osuo/docker-backup backup $2

