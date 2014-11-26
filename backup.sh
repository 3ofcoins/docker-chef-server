#!/bin/sh
set -e

: ${KNIFE_HOME:=/etc/chef}
export KNIFE_HOME

ts=$(date -u +%Y%m%dT%H%M%SZ)
destdir=/var/opt/opscode/backup/$ts

mkdir -p $destdir
cd $destdir

mkdir users
for user in $(chef-server-ctl user-list) ; do
    chef-server-ctl user-show -l -F json $user > users/$user.json
done

mkdir organizations
for org in $(chef-server-ctl org-list) ; do
    chef-server-ctl org-show -l -F json $org > organizations/$org.json
    mkdir organizations/$org
    env CHEF_ORGANIZATION=$org knife download --chef-repo-path=organizations/$org /
done

cd ..
hardlink -t .

test -d latest~ && rm -rf latest~
test -d latest && mv latest latest~
cp -al $ts latest
rm -rf latest~
