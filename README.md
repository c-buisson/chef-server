# chef-server

chef-server is running Chef server 11 on an Ubuntu Trusty 14.04 LTS

This is a fork of: [base/chef-server](https://registry.hub.docker.com/u/base/chef-server/).

## Environment
Chef is running over HTTPS/4443 by default. You can however change that to 443 by updating `chef-server.rb` and the Nginx listen port in `run.sh`.

## Usage
*With log output:*

```
$ docker run --privileged --name chef-server -d -v ~/chef-logs:/var/log -v ~/install-chef-out:/root -p 4443:4443 cbuisson/chef-server
```

*Just the container:*

```
$ docker run --privileged --name chef-server -d -p 4443:4443 cbuisson/chef-server
```

Once the Chef server is configured, you download the Knife admin keys here:

```
$ curl -Ok https://IP:4443/knife_admin_key.tar.gz
```

Then un-tar that archive and point your knife.rb to the `admin.pem` and `chef-validator.pem` files.
