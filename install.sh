#!/bin/sh
set -e -x

SERVER_VERSION="12.8.0"
SERVER_SHA1="4111123ba0c869e26a069f6d4625ad193e27ec99"
CLIENT_VERSION="12.12.13"
CLIENT_SHA1="e4db4a79ea6d8dac04829a13b489df77085a067e"

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes logrotate vim-nox hardlink wget ca-certificates

# Download and install Chef's packages
wget -nv --no-check-certificate https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_${SERVER_VERSION}-1_amd64.deb
wget -nv --no-check-certificate https://packages.chef.io/stable/ubuntu/14.04/chef_${CLIENT_VERSION}-1_amd64.deb

sha1sum -c - <<EOF
${SERVER_SHA1}  chef-server-core_${SERVER_VERSION}-1_amd64.deb
${CLIENT_SHA1}  chef_${CLIENT_VERSION}-1_amd64.deb
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

# Cleanup
cd /
rm -rf $tmpdir /tmp/install.sh /var/lib/apt/lists/* /var/cache/apt/archives/*
