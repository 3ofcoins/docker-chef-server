#!/bin/sh
set -e -x

## You can update the versions and SHA256 from the download page in
## comments above.
# https://downloads.chef.io/chef-server#ubuntu
SERVER_VERSION="12.18.14"
SERVER_SHA256="2be59db9ac71c5595ffd605e96de81fc3ef36aa4756fa73b2be9a53edbfce809"
# https://downloads.chef.io/chef/14.6.47#ubuntu
CLIENT_VERSION="14.6.47"
CLIENT_SHA256="81dc8634609493a8e9c9dbcb027855027812c902db95e1884b18fe368acbd047"

# Temporary work dir
tmpdir="`mktemp -d`"
cd "$tmpdir"

# Install prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update -q --yes
apt-get install -q --yes logrotate vim-nox hardlink wget ca-certificates

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

# Cleanup
cd /
rm -rf $tmpdir /tmp/install.sh /var/lib/apt/lists/* /var/cache/apt/archives/*
