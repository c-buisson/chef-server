#/bin/bash -x

chef-server-ctl reconfigure |tee /root/out.txt

URL="http://127.0.0.1:8000/_status"
CODE=1
SECONDS=0
TIMEOUT=60

return=`curl -sf ${URL}`
echo "${URL} returns: ${return}" >> /root/out.txt

if [[ -z "$return" ]]; then
  echo "Error while running chef-server-ctl reconfigure" >> /root/out.txt
  echo "Blocking until <${URL}> responds..." >> /root/out.txt

  while [ $CODE -ne 0 ]; do

    curl -sf \
         --connect-timeout 3 \
         --max-time 5 \
         --fail \
         --silent \
         ${URL}

    CODE=$?

    sleep 2
    echo -n "." >> /root/out.txt

    if [ $SECONDS -ge $TIMEOUT ]; then
      echo "$URL is not available after $SECONDS seconds...stopping the script!" >> /root/out.txt
      exit 1
    fi

  done;
  echo -e "\n$URL is available!\n" >> /root/out.txt

  chef-server-ctl reconfigure |tee /root/out.txt
fi
