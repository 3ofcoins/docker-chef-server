#!/bin/sh
set -e -x

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes logrotate vim-nox hardlink wget ca-certificates apt-transport-https telnet curl nano

# Download and install Chef's packages
wget -nv https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_12.4.1-1_amd64.deb
wget -nv https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.7.2-1_amd64.deb

sha1sum -c - <<EOF
a75e8dbcce749adf61a60ca0ccf25fc041e4774a  chef-server-core_12.4.1-1_amd64.deb
9bc701d90ba12c71fbe51a8bdcdf25e864375f4e  chef_12.7.2-1_amd64.deb
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
