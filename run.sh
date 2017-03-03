#!/bin/bash -xe
sysctl -w kernel.shmmax=17179869184
/opt/opscode/embedded/bin/runsvdir-start &
if [ -f "/root/chef_configured" ]
  then
    echo -e "\nChef Server already configured!\n" |tee -a /root/out.txt
    chef-server-ctl status |tee -a /root/out.txt
  else
    /usr/local/bin/configure_chef.sh
    sed -i "s,    listen 443;,    listen $CHEF_PORT;,g" /var/opt/opscode/nginx/etc/chef_https_lb.conf
    sed -i '$i\    location /knife_admin_key.tar.gz {\n      default_type application/zip;\n      alias /etc/chef/knife_admin_key.tar.gz;\n    }' /var/opt/opscode/nginx/etc/chef_https_lb.conf
    echo -e "\nCreating tar file with the Knife keys" |tee -a /root/out.txt
    cd /etc/chef/ && tar -cvzf knife_admin_key.tar.gz admin.pem admin-validator.pem
    echo -e "\nRestart Nginx..." |tee -a /root/out.txt
    chef-server-ctl restart nginx
    chef-server-ctl status |tee -a /root/out.txt
    touch /root/chef_configured
    echo -e "\n\nDone!\n" |tee -a /root/out.txt
fi
tail -F /opt/opscode/embedded/service/*/log/current
