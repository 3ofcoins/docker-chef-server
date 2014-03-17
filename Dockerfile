# -*- conf -*-

FROM ubuntu:12.04
MAINTAINER Maciej Pasternacki <maciej@3ofcoins.net>

ENV PATH /opt/chef-server/embedded/sbin:/opt/chef-server/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EXPOSE 80 443
VOLUME /var/opt/chef-server

ADD https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.11-1.ubuntu.12.04_amd64.deb
# ADD chef-server_11.0.11-1.ubuntu.12.04_amd64.deb /chef-server.deb
RUN dpkg -i /chef-server.deb && rm -v /chef-server.deb

ADD bootstrap-run /opt/chef-server/sv/bootstrap/run
ADD bootstrap-finish /opt/chef-server/sv/bootstrap/finish
ADD chef-server.rb /etc/chef-server/chef-server.rb

CMD [ "/opt/chef-server/embedded/bin/runsvdir", "-P", "/opt/chef-server/sv", "log: ..........................................................................................................................................................................................................................................................................................................................................................................................................." ]
