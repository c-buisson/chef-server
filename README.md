# chef-server

chef-server is running Chef server 11 on an Ubuntu Trusty 14.04 LTS

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
Chef is running over HTTPS/443 by default. You can however change that to another port by updating the `CHEF_PORT` variable and the expose port `-p`.

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
$ curl -Ok https://IP:CHEF_PORT/knife_admin_key.tar.gz
```

Then un-tar that archive and point your knife.rb to the `admin.pem` and `chef-validator.pem` files.
