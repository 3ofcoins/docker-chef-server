# -*- conf -*-

FROM ubuntu:12.04
#TAG 11.1.1
MAINTAINER Maciej Pasternacki <maciej@3ofcoins.net>

ENV PATH /opt/chef-server/embedded/sbin:/opt/chef-server/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EXPOSE 80 443
VOLUME /var/opt/chef-server

ADD https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.1.1-1_amd64.deb /chef-server.deb
RUN dpkg -i /chef-server.deb && rm -v /chef-server.deb

ADD init.rb /init.rb
ADD chef-server.rb /etc/chef-server/chef-server.rb

CMD [ "/opt/chef-server/embedded/bin/ruby", "/init.rb" ]
