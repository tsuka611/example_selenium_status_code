#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "$0 url"
  exit 1
fi

BASE_DIR=$(cd `dirname $0`/..; pwd)
cd $BASE_DIR

docker-compose exec app ruby src/status_get.rb "$1"
