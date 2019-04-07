#!/bin/bash

source ../variables

docker run \
    --detach \
    --volume $PWD/data:/var/lib/mysql \
    --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
    --name openstack-mysql \
    --publish 13306:3306 \
    mysql:5.6.27
