#!/usr/bin/env bash

BASE_DIR=$(cd `dirname $0`/..; pwd)
cd $BASE_DIR

docker-compose run --rm --no-deps app bundle install
if [ $? -ne 0 ]; then
  echo "Bundle install failed."
  exit 1
fi

docker-compose up
