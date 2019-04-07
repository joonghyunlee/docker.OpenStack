#!/bin/bash

# init arguments
ADMIN_TOKEN=${ADMIN_TOKEN:-`openssl rand -hex 10`}
ADMIN_TENANT_NAME=${ADMIN_TENANT_NAME:-admin}
ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-New1234!}

OS_TOKEN=$ADMIN_TOKEN
OS_URL=${OS_URL:-http://${HOSTNAME}:35357/v3}
OS_IDENTITY_API_VERSION=3

# configure Keystone Service
openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
openstack-config --set /etc/keystone/keystone.conf DEFAULT use_stder True
openstack-config --set /etc/keystone/keystone.conf database connection ${CONNECTION:-mysql://keystone:6HN6gbDNtFY@openstack-mysql/keystone}
cat /etc/keystone/keystone.conf

# initialize Fernet keys
keystone-manage fernet_setup --keystone-user root --keystone-group root
mv /etc/keystone/default_catalog.templates /etc/keystone/default_catalog

su keystone -s /bin/sh -c "keystone-manage db_sync"

ls -al /usr/bin/
ls -al /usr/share/keystone/
systemctl list-unit-files | grep enabled

cp /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
rm -rf /run/httpd/* /tmp/httpd*
exec /usr/sbin/apachectl -DFOREGROUND

# initialize account
openstack service create --name keystone identity
openstack endpoint create --region RegionOne identity public http://${HOSTNAME}:5000/v3
openstack endpoint create --region RegionOne identity internal http://${HOSTNAME}:5000/v3
openstack endpoint create --region RegionOne identity admin http://${HOSTNAME}:5000/v3

openstack domain create --description "Default Domain" default
openstack project create --domain default --description "Admin Project" $ADMIN_TENANT_NAME
openstack user create --domain default --password $ADMIN_PASSWORD $ADMIN_USERNAME

openstack role create admin
openstack role add --project $ADMIN_TENANT_NAME --user $ADMIN_USERNAME admin

cat > ~/keystonerc <<EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=${ADMIN_TENANT_NAME}
export OS_USERNAME=${ADMIN_USERNAME}
export OS_PASSWORD=${ADMIN_PASSWORD}
export OS_AUTH_URL=http://${HOSTNAME}:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
