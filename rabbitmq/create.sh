#!/bin/bash

RABBITMQ_CONTAINER_NAME=rabbitmq

docker \
    run \
    --detach \
    --volume $PWD/data:/data \
    --name ${RABBITMQ_CONTAINER_NAME} \
    --env RABBITMQ_DEFAULT_USER=openstack \
    --env RABBITMQ_DEFAULT_PASS='123qwe' \
    --restart=unless-stopped \
    --publish 5672:5672 \
    --publish 15672:15672 \
    rabbitmq:3.6-management
