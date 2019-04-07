#!/bin/bash

source ../variables

if [ -z $1 ]
then
    docker exec -it openstack-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD}
elif [ "$1" == "keystone" ]
then
    docker exec -it openstack-mysql mysql -u keystone -p${KEYSTONE_PASSWORD} -D keystone
fi
