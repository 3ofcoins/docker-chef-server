#!/bin/sh
set -e -x

SERVER_VERSION="12.13.0"
SERVER_SHA256="e1c6a092f74a6b6b49b47dd92afa95be3dd9c30e6b558da5adf943a359a65997"
CLIENT_VERSION="12.19.36"
CLIENT_SHA256="fbf44670ab5b76e4f1a1f5357885dafcc79e543ccbbe3264afd40c15d604b6dc"

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes \
    logrotate \
    vim-nox \
    hardlink \
    wget \
    ca-certificates \
    upstart-sysv

# Download and install Chef's packages
wget -nv https://packages.chef.io/files/stable/chef-server/${SERVER_VERSION}/ubuntu/16.04/chef-server-core_${SERVER_VERSION}-1_amd64.deb
wget -nv https://packages.chef.io/files/stable/chef/${CLIENT_VERSION}/ubuntu/16.04/chef_${CLIENT_VERSION}-1_amd64.deb

sha256sum -c - <<EOF
${SERVER_SHA256}  chef-server-core_${SERVER_VERSION}-1_amd64.deb
${CLIENT_SHA256}  chef_${CLIENT_VERSION}-1_amd64.deb
EOF

dpkg -i chef-server-core_${SERVER_VERSION}-1_amd64.deb chef_${CLIENT_VERSION}-1_amd64.deb

# Extra setup
rm -rf /etc/opscode
mkdir -p /etc/cron.hourly
ln -sfv /var/opt/opscode/log /var/log/opscode
ln -sfv /var/opt/opscode/etc /etc/opscode
ln -sfv /opt/opscode/sv/logrotate /opt/opscode/service
ln -sfv /opt/opscode/embedded/bin/sv /opt/opscode/init/logrotate
chef-apply -e 'chef_gem "knife-opc"'

# Required if adding plugins
rm -rf /opt/chef-manage/service
mkdir -p /opt/chef-manage
ln -sf /opt/opscode/service /opt/chef-manage/service

# Cleanup
cd /
rm -rf $tmpdir /tmp/install.sh /var/lib/apt/lists/* /var/cache/apt/archives/*
