FROM ubuntu:14.04
MAINTAINER Clement Buisson <clement.buisson@gmail.com>
#This is a fork of base/chef-server

RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -yq wget curl
RUN wget --content-disposition "http://www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false"
RUN dpkg -i chef-server*.deb

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

ADD reconfigure_chef.sh /usr/local/bin/
ADD run.sh /usr/local/bin/
CMD rsyslogd -n
VOLUME /root/
VOLUME /var/log
CMD ["run.sh"]
