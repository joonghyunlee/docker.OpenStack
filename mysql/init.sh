#!/bin/bash

source ../variables

docker exec openstack-mysql \
    mysql -u root -p${MYSQL_ROOT_PASSWORD} \
    -e"GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_PASSWORD}';
       GRANT ALL ON keysotne.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_PASSWORD}';
       flush privileges;"
