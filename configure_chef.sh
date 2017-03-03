#/bin/bash -x

cat > /etc/opscode/chef-server.rb << EOL
nginx['enable_non_ssl']=false
nginx['ssl_port']=$CHEF_PORT
EOL
if [[ ! -z $CONTAINER_NAME ]]; then
  echo "nginx['server_name']=\"$CONTAINER_NAME\"" >> /etc/opscode/chef-server.rb
else
  echo "nginx['server_name']=\"chef-server\"" >> /etc/opscode/chef-server.rb
fi

chef-server-ctl reconfigure |tee /root/out.txt

URL="http://127.0.0.1:8000/_status"
CODE=1
SECONDS=0
TIMEOUT=60

return=`curl -sf ${URL}`
echo "${URL} returns: ${return}" |tee -a /root/out.txt

if [[ -z "$return" ]]; then
  echo "Error while running chef-server-ctl reconfigure" |tee -a /root/out.txt
  echo -e "Blocking until <${URL}> responds...\n" |tee -a /root/out.txt

  while [ $CODE -ne 0 ]; do

    curl -sf \
         --connect-timeout 3 \
         --max-time 5 \
         --fail \
         --silent \
         ${URL}

    CODE=$?

    sleep 2
    echo -n "." |tee -a /root/out.txt

    if [ $SECONDS -ge $TIMEOUT ]; then
      echo "$URL is not available after $SECONDS seconds...stopping the script!" |tee -a /root/out.txt
      exit 1
    fi
  done;

  echo -e "\n\n$URL is available!\n" |tee -a /root/out.txt
  echo -e "\nSetting up admin user and default organization" |tee -a /root/out.txt
  chef-server-ctl user-create admin Admin User admin@myorg.com "passwd"  --filename /etc/chef/admin.pem |tee -a /root/out.txt
  chef-server-ctl org-create my_org "Default organization" --association_user admin --filename /etc/chef/admin-validator.pem |tee -a /root/out.txt
  echo -e "\nRunning: chef-server-ctl install chef-manage" |tee -a /root/out.txt
  chef-server-ctl install chef-manage |tee -a /root/out.txt
  echo -e "\nRunning: chef-server-ctl reconfigure" |tee -a /root/out.txt
  chef-server-ctl reconfigure |tee -a /root/out.txt
  echo "{ \"error\": \"Please use https:// instead of http:// !\" }" > /var/opt/opscode/nginx/html/500.json
  sed -i "s,/503.json;,/503.json;\n    error_page 497 =503 /500.json;,g" /var/opt/opscode/nginx/etc/chef_https_lb.conf
  sed -i '$i\    location /knife_admin_key.tar.gz {\n      default_type application/zip;\n      alias /etc/chef/knife_admin_key.tar.gz;\n    }' /var/opt/opscode/nginx/etc/chef_https_lb.conf
  echo -e "\nCreating tar file with the Knife keys" |tee -a /root/out.txt
  cd /etc/chef/ && tar -cvzf knife_admin_key.tar.gz admin.pem admin-validator.pem
  echo -e "\nRestart Nginx..." |tee -a /root/out.txt
  chef-server-ctl restart nginx
  chef-server-ctl status |tee -a /root/out.txt
  touch /root/chef_configured
  echo -e "\n\nDone!\n" |tee -a /root/out.txt
fi
