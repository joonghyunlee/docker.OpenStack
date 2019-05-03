#!/bin/bash

# init arguments
ADMIN_TENANT_NAME=${ADMIN_TENANT_NAME:-admin}
ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-New1234!}
OS_REGION_NAME=${OS_REGION_NAME:-RegionOne}
OS_URL=${OS_URL:-http://${HOSTNAME}:5000/v3}
OS_IDENTITY_API_VERSION=3

KEYSTONE_DB_HOST=${KEYSTONE_DB_HOST:openstack-mysql}
KEYSTONE_DB_PASS=${KEYSTONE_DB_PASSWORD:-6HN6gbDNtFY}

# configure Keystone Service
openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
openstack-config --set /etc/keystone/keystone.conf DEFAULT use_stder True
openstack-config --set /etc/keystone/keystone.conf database connection ${CONNECTION:-mysql+pymysql://keystone:${KEYSTONE_DB_PASS}@${KEYSTONE_DB_HOST}/keystone}
openstack-config --set /etc/keystone/keystone.conf token provider fernet
cat /etc/keystone/keystone.conf

# bootstrap Keystone Service
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
mv /etc/keystone/default_catalog.templates /etc/keystone/default_catalog
chown -R keystone:keystone /etc/keystone

su keystone -s /bin/sh -c "keystone-manage db_sync"

keystone-manage bootstrap --bootstrap-password ${ADMIN_PASSWORD} \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id ${OS_REGION_NAME}

/usr/bin/keystone-wsgi-admin --port 35357 &

cat > /keystonerc <<EOF
export OS_TOKEN=${ADMIN_TOKEN}
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=${ADMIN_TENANT_NAME}
export OS_USERNAME=${ADMIN_USERNAME}
export OS_PASSWORD=${ADMIN_PASSWORD}
export OS_REGION_NAME=${OS_REGION_NAME}
export OS_AUTH_URL=http://${HOSTNAME}:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

# Launch httpd for Keystone
cp /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
rm -rf /run/httpd/* /tmp/httpd*
exec /usr/sbin/apachectl -DFOREGROUND
