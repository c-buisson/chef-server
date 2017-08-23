#!/bin/bash -e
sysctl -wq kernel.shmmax=17179869184
/opt/opscode/embedded/bin/runsvdir-start &
if [ -f "/root/chef_configured" ]
  then
    echo -e "\nChef Server already configured!\n"
    chef-server-ctl status
  else
    echo -e "\nNew install of Chef-Server!"
    /usr/local/bin/configure_chef.sh
fi
tail -F /opt/opscode/embedded/service/*/log/current
