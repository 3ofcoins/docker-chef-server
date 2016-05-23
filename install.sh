#!/bin/sh
set -e -x

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes logrotate vim-nox hardlink wget ca-certificates

# Download and install Chef's packages
wget -nv https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.6.0-1_amd64.deb
wget -nv https://packages.chef.io/stable/ubuntu/10.04/chef_12.10.24-1_amd64.deb

sha1sum -c - <<EOF
eafc7aedd4966457cd77eb51f75da863947dde70  chef-server-core_12.6.0-1_amd64.deb
7d30b300f95f00036919ee8bf3b95ab73429e57e  chef_12.10.24-1_amd64.deb
EOF

dpkg -i chef-server-core_12.4.1-1_amd64.deb chef_12.7.2-1_amd64.deb

# Extra setup
rm -rf /etc/opscode
mkdir -p /etc/cron.hourly
ln -sfv /var/opt/opscode/log /var/log/opscode
ln -sfv /var/opt/opscode/etc /etc/opscode
ln -sfv /opt/opscode/sv/logrotate /opt/opscode/service
ln -sfv /opt/opscode/embedded/bin/sv /opt/opscode/init/logrotate
chef-apply -e 'chef_gem "knife-opc"'

# Cleanup
cd /
rm -rf $tmpdir /tmp/install.sh /var/lib/apt/lists/* /var/cache/apt/archives/*
