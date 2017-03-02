FROM ubuntu:14.04
MAINTAINER Clement Buisson <clement.buisson@gmail.com>
#This is a fork of base/chef-server

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget curl && \
    wget --no-check-certificate --content-disposition "http://www.opscode.com/chef/download-server?p=ubuntu&pv=14.04&m=x86_64&v=11&prerelease=false&nightlies=false" && \
    dpkg -i chef-server*.deb && \
    rm chef-server*.deb && \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/*

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

ADD reconfigure_chef.sh /usr/local/bin/
ADD run.sh /usr/local/bin/
CMD rsyslogd -n
VOLUME /root/
VOLUME /var/log
CMD ["run.sh"]
