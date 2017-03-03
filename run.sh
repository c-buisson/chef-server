#!/bin/bash -xe
sysctl -w kernel.shmmax=17179869184
/opt/opscode/embedded/bin/runsvdir-start &
if [ -f "/root/chef_configured" ]
  then
    echo -e "\nChef Server already configured!\n" |tee -a /root/out.txt
    chef-server-ctl status |tee -a /root/out.txt
  else
    /usr/local/bin/configure_chef.sh
fi
tail -F /opt/opscode/embedded/service/*/log/current
