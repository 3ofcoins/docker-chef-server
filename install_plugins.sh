#!/bin/sh
set +x

echo "INSTALLING PLUGINS"
echo "Install Chef Manage"
{
    chef-server-ctl install chef-manage
} || {
	echo "Sometimes packagecloud exception is raised in apt-get and we need to clear cached apt sources"
    rm -rf /var/lib/apt/lists/*
    chef-server-ctl install chef-manage
}
chef-manage-ctl reconfigure

echo "Install Reporting"
chef-server-ctl install opscode-reporting
opscode-reporting-ctl reconfigure

echo "Install Chef Push"
chef-server-ctl install opscode-push-jobs-server
opscode-push-jobs-server-ctl reconfigure

echo "Install Chef Sync"
chef-server-ctl install chef-sync
echo "chef-sync-ctl reconfigure"

echo "Plugins installed"
