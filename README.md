# chef-server

chef-server will run Chef Server 12 in an Ubuntu Trusty 14.04 LTS container.<br>
Image Size: 1.124 GB

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
Chef is running over HTTPS/443 by default. You can however change that to another port by updating the `CHEF_PORT` variable and the expose port `-p`.

## Start the container
*Launch the container:*

```
$ docker run --privileged -e CHEF_PORT=443 --name chef-server -d -p 443:443 cbuisson/chef-server
```

*Launch the container with logs volumes:*

```
$ docker run --privileged -e CHEF_PORT=443 --name chef-server -d -v ~/chef-logs:/var/log -v ~/install-chef-out:/root -p 443:443 cbuisson/chef-server
```
<br>
**Note:** By default `chef-server-ctl reconfigure` will create SSL certificates based on the container's FQDN (i.e "103d6875c1c5" which is its "CONTAINER ID"), I have changed that behiavior to always have a SSL certificate file named "chef-server.crt". You can change the certificate name by adding  `-e CONTAINER_NAME=new_name` to the `docker run` command. Remember to reflect that change in config.rb!

'chef-server' or $CONTAINER_NAME **need to be resolvable by hostname!**

## Setup knife

Once Chef Server 12 is configured, you can download the Knife admin keys here:

```
curl -Ok https://chef-server:$CHEF_PORT/knife_admin_key.tar.gz
```

Then un-tar that archive and point your config.rb to the `admin.pem` and `admin-validator.pem` files.

*config.rb* example:

```ruby
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '/home/cbuisson/.chef/admin.pem'
validation_client_name   'admin-validator'
validation_key           '/home/cbuisson/.chef/admin-validator.pem'
chef_server_url          'https://chef-server:$CHEF_PORT/organizations/my_org'
```

When the config.rb file is ready, you will need to get the SSL certificate file from the container to access Chef Server:

```bash
cbuisson@t530:~/.chef# knife ssl fetch
WARNING: Certificates from chef-server will be fetched and placed in your trusted_cert
directory (/home/cbuisson/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for chef-server in /home/cbuisson/.chef/trusted_certs/chef-server.crt
```

You should now be able to use the knife command!
```bash
cbuisson@t530:~# knife user list
admin
```
**Done!**

##### Note
Chef-Server running inside a container isn't officially supported by [Chef](https://www.chef.io/about/) and as a result the webui isn't available.<br>
However the webui is not a required since you can interact with Chef-Server with the `knife` and `chef-server-ctl` commands.

##### Tags
v1.0: Chef Server 11<br>
v2.X: Chef Server 12
