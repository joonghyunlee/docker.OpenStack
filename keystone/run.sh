#!/bin/bash

docker run \
    --privileged \
    --detach \
    --name keystone \
    --hostname keystone \
    --link openstack-mysql \
    --publish 5000:5000 \
    --publish 35357:35357 \
    openstack-keystone-uuid
