FROM index.docker.io/centos:7

RUN yum update -y && \
    yum install -y centos-release-openstack-rocky && \
    yum install -y httpd mod_wsgi && \
    yum install -y openstack-keystone openstack-utils openstack-selinux && \
    yum clean all

COPY bootstrap.sh /tmp/bootstrap.sh
RUN chown root:root /tmp/bootstrap.sh & chmod a+x /tmp/bootstrap.sh

ENTRYPOINT ["/tmp/bootstrap.sh"]
EXPOSE 5000 35357
