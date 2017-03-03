#/bin/bash -x

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
fi
