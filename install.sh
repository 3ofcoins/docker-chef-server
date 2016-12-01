#!/bin/sh
set -e -x

SERVER_VERSION="12.10.0"
SERVER_SHA1="95fce9f167972418b3f06b9e5fe95f8a3f0e5361"
CLIENT_VERSION="12.16.42"
CLIENT_SHA1="e720803538b5db3cc9924121e3aa9e5a7a03cf79"

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes logrotate vim-nox hardlink wget ca-certificates upstart-sysv # chefserver is not yet compatible with systemd
update-initramfs -u

# Download and install Chef's packages
wget -nv https://packages.chef.io/stable/ubuntu/16.04/chef-server-core_${SERVER_VERSION}-1_amd64.deb
wget -nv https://packages.chef.io/stable/ubuntu/16.04/chef_${CLIENT_VERSION}-1_amd64.deb

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
