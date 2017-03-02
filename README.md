# chef-server

chef-server is running Chef Server 11 in a Ubuntu Trusty 14.04 LTS container.
Image Size: 1.025 GB

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
Chef is running over HTTPS/443 by default. You can however change that to another port by updating the `CHEF_PORT` variable and the expose port `-p`.

You will need to use Chef 11.X in order to be able to use Knife.
Check Knife's version:
```bash
cbuisson@t530:~# knife -v
Chef: 11.16.4
```
*If you have Chef 12 installed on your Docker server, you will need to use* `knife ssl fetch` *in order to get the SSL certificates from the container. Don't forget to update `chef_server_url` with the container ID in knife.rb!*

## Usage
*With log output:*

```
$ docker run --privileged -e CHEF_PORT=443 --name chef-server -d -v ~/chef-logs:/var/log -v ~/install-chef-out:/root -p 443:443 cbuisson/chef-server
```

*Just the container:*

```
$ docker run --privileged -e CHEF_PORT=443 --name chef-server -d -p 443:443 cbuisson/chef-server
```

Once the Chef server is configured, you can download the Knife admin keys here:

```
$ curl -Ok https://IP_HOST:CHEF_PORT/knife_admin_key.tar.gz
```

Then un-tar that archive and point your knife.rb to the `admin.pem` and `chef-validator.pem` files.

*knife.rb* example:
```bash
log_level                :info
log_location             STDOUT
cache_type               'BasicFile'
node_name                'admin'
client_key               '/home/cbuisson/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/home/cbuisson/.chef/chef-validator.pem'
chef_server_url          'https://IP_HOST:CHEF_PORT'
```
