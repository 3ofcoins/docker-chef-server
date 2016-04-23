# -*- conf -*-

FROM ubuntu:14.04
MAINTAINER Maciej Pasternacki <maciej@3ofcoins.net>

EXPOSE 80 443 10000 10002

# Switched to use entire /var/opt as volume, but keeping all options in the list for reference
#VOLUME /var/opt/opscode /var/opt /var/opt/chef-backup /var/opt/chef-manage /var/opt/chef-server /var/opt/chef-sync /var/opt/opscode-push-jobs-server
VOLUME /var/opt

COPY install.sh /tmp/install.sh
RUN [ "/bin/sh", "/tmp/install.sh" ]

COPY install_plugins.sh /tmp/install_plugins.sh
RUN [ "/bin/sh", "/tmp/install_plugins.sh" ]

COPY init.rb /init.rb
COPY chef-server.rb /.chef/chef-server.rb
COPY logrotate /opt/opscode/sv/logrotate
COPY knife.rb /etc/chef/knife.rb
COPY backup.sh /usr/local/bin/chef-server-backup

ENV KNIFE_HOME /etc/chef

CMD [ "/opt/opscode/embedded/bin/ruby", "/init.rb" ]


