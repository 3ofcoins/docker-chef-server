# -*- conf -*-

FROM ubuntu:12.04
#TAG 12.0.0-rc.6
MAINTAINER Maciej Pasternacki <maciej@3ofcoins.net>

EXPOSE 80 443
VOLUME /var/opt/opscode

ADD https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.0.0-rc.6-1_amd64.deb /tmp/chef-server-core.deb
ADD https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.16.4-1_amd64.deb /tmp/chef.deb

RUN set -e -x ; \
    export DEBIAN_FRONTEND=noninteractive ; \
    apt-get update -q --yes ; \
    apt-get install -q --yes logrotate vim-nox ; \
    dpkg -i /tmp/chef-server-core.deb /tmp/chef.deb ; \
    rm -rf /tmp/*.deb /var/lib/apt/lists/* /var/cache/apt/archives/* ; \
    mkdir -p /etc/cron.hourly ; \
    ln -sfv /var/opt/opscode/log /var/log/opscode ; \
    ln -sfv /var/opt/opscode/etc /etc/opscode ; \
    ln -sfv /opt/opscode/sv/logrotate /opt/opscode/service ; \
    ln -sfv /opt/opscode/embedded/bin/sv /opt/opscode/init/logrotate

ADD init.rb /init.rb
ADD chef-server.rb /.chef/chef-server.rb
ADD logrotate /opt/opscode/sv/logrotate

CMD [ "/opt/opscode/embedded/bin/ruby", "/init.rb" ]
