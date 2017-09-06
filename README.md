# chef-server

chef-server will run Chef Server 12 in an Ubuntu Trusty 14.04 LTS container.  
Image Size: Approximately 1GB

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
##### Protocol / Port
Chef is running over HTTPS/443 by default.  
You can however change that to another port by adding `-e SSL_PORT=new_port` to the `docker run` command below and update the expose port `-p` accordingly.

##### SSL certificate
When Chef Server gets configured it creates an SSL certificate based on the container's FQDN (i.e "103d6875c1c5" which is the "CONTAINER ID"). This default behiavior has been changed to always produce an SSL certificate file named "chef-server.crt".  
You can change the certificate name by adding  `-e CONTAINER_NAME=new_name` to the `docker run` command. Remember to reflect that change in config.rb!

##### Logs
`/var/log/` is accessible via a volume directory. Feel free to optionally to use it with the `docker run` command above by adding: `-v ~/chef-logs:/var/log`

##### DNS
The container needs to be **DNS resolvable!**  
Be sure **'chef-server'** or **$CONTAINER_NAME** is pointing to the container's IP!  
This needs to be done to match the SSL certificate name with the `chef_server_url ` from knife's `config.rb` file.

## Start the container
Docker command:

```bash
$ docker run --privileged -t --name chef-server -d -p 443:443 cbuisson/chef-server
```

Follow the installation:

```bash
$ docker logs -f chef-server
```

## Setup knife

Once Chef Server 12 is configured, you can download the Knife admin keys here:

```bash
curl -Ok https://chef-server:$SSL_PORT/knife_admin_key.tar.gz
```

Then un-tar that archive and point your config.rb to the `admin.pem` and `my_org-validator.pem` files.

*config.rb* example:

```ruby
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '/home/cbuisson/.chef/admin.pem'
validation_client_name   'my_org-validator'
validation_key           '/home/cbuisson/.chef/my_org-validator.pem'
chef_server_url          'https://chef-server:$SSL_PORT/organizations/my_org'
```

When the config.rb file is ready, you will need to get the SSL certificate file from the container to access Chef Server:

```bash
cbuisson@server:~/.chef# knife ssl fetch
WARNING: Certificates from chef-server will be fetched and placed in your trusted_cert
directory (/home/cbuisson/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for chef-server in /home/cbuisson/.chef/trusted_certs/chef-server.crt
```

You should now be able to use the knife command!
```bash
cbuisson@server:~# knife user list
admin
```
**Done!**

##### Note
Chef-Server running inside a container isn't officially supported by [Chef](https://www.chef.io/about/) and as a result the webui isn't available.  
However the webui is not required since you can interact with Chef-Server via the `knife` and `chef-server-ctl` commands.

##### Tags
v1.0: Chef Server 11  
v2.x: Chef Server 12
