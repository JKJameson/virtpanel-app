#!/bin/bash -e
docker build --pull -t virtpanel/app:swoole . -f Dockerfile.swoole

docker container create --name extract virtpanel/app:swoole
docker container cp extract:/usr/local/lib/php/extensions/no-debug-non-zts-20210902/openswoole.so ./openswoole/openswoole.so
docker container cp extract:/usr/local/include/php/ext/openswoole/php_openswoole.h ./openswoole/php_openswoole.h
docker container cp extract:/usr/local/include/php/ext/openswoole/config.h ./openswoole/config.h
docker container rm -f extract

docker build --pull -t virtpanel/app .
