Frozen CDN
==========

In early 2012 [we](http://www.nonfiction.ca/) were looking for a content distribution network for our websites that wasn't terrible and was affordable. Akamai wouldn't talk to us unless we were doing hundreds of TB / second and most of the others did things old school: upload your files everytime it changed - that just wasn't acceptable to us.

Due to my experience with [Varnish](https://www.varnish-cache.org/), I thought I would be able to build a system that used Varnish to do this - so I set out to try.

We used these components:

1. Amazon Web Services - due to it's global reach and low initial investment - we could build on this without buying servers.
2. Zerigo - [GeoDNS](https://www.zerigo.com/news/launch-of-geodns-geolocation-load-balancing) allowed us to route requests closest to the users.
3. [Opscode Chef](http://www.opscode.com/chef/) - to manage and build the servers upon launch.
4. Ruby on Rails - [central configuration and management interface](https://github.com/darron/frozen-cdn_fe).

Within a month \(working 1 - 2 days a week\) on it I had a prototype.

To add nodes to the CDN:

1. We would launch a Varnish server in the one of the AWS Regions. It would grab its first initial config file from the central server.
2. Direct requests to it via DNS assignment.
3. Add the node to the central server admin interface - that would ensure updated config files were pushed out when they changed.

There were 3 types of servers:

1. App server - housed the central Rails config software.
2. Counter server - received logfiles from each server and added statistics to a Redis server.
3. Varnish server - did the actual serving of websites.

To Deploy the App and Counter Servers
------------

```
knife ec2 server create -r "role[setup],role[app]" -I ami-349b495d -f m1.small -S key -G varnish -x ubuntu --region us-east-1 -Z us-east-1b --node-name app-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/a-key.pem
knife ec2 server create -r "role[setup],role[counter]" -I ami-349b495d -f m1.small -S key -G varnish -x ubuntu --region us-east-1 -Z us-east-1b --node-name counter-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/a-key.pem
```

That takes care of the servers needed to operate the system.

To Deploy a Varnish Server
------------

```
# In USE-1
knife ec2 server create -r "role[setup],role[varnish]" -I ami-349b495d -f m1.small -S key -G varnish -x ubuntu --region us-east-1 -Z us-east-1b --node-name use1-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/a-key.pem
# In USW-1
knife ec2 server create -r "role[setup],role[varnish]" -I ami-7fb0e93a -f m1.small -S other-key -G varnish -x ubuntu --region us-west-1 -Z us-west-1a --node-name usw1-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/another-key.pem
# In EUW-1
knife ec2 server create -r "role[setup],role[varnish]" -I ami-fb665f8f -f m1.small -S yet-another-key -G varnish -x ubuntu --region eu-west-1 -Z eu-west-1b --node-name euw1-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/yet-another-key.pem
# In APNE-1
knife ec2 server create -r "role[setup],role[varnish]" -I ami-942f9995 -f m1.small -S yet-another-key -G varnish -x ubuntu --region ap-northeast-1 -Z ap-northeast-1a --node-name jp1-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/yet-another-key.pem
# In APSE-1
knife ec2 server create -r "role[setup],role[varnish]" -I ami-7089cd22 -f m1.small -S yet-another-key -G varnish -x ubuntu --region ap-southeast-1 -Z ap-southeast-1a --node-name ph1-01 --distro ubuntu10.04-ruby187 -i ~/.ssh/yet-another-key.pem
# Also deployed to Brazil and USW-2.
```

It worked really well and handled over 100 million hits in the 3 months of production testing - but then we discovered [Fastly](http://www.fastly.com/) and abandoned the prototype. Fastly did what we did, but better, faster and cheaper.

This is being posted for archival purposes.