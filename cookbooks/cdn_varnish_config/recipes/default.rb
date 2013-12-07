#
# Cookbook Name:: cdn_varnish_config
# Recipe:: default
#
# Copyright 2012, Darron Froese
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Register the new node and ip in the databag.
new_varnish_node = {
  "id" => node.name,
  "ip" => node.ec2.public_ipv4
}

databag_item = Chef::DataBagItem.new
databag_item.data_bag("varnish_nodes")
databag_item.raw_data = new_varnish_node 
databag_item.save

service "varnish" do
  service_name "varnish"
  restart_command "/usr/sbin/service varnish restart"
  reload_command "/usr/sbin/service varnish reload"
  action [:enable, :start]
end

bash "grab a new config file" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    mv -f /home/vcl/default.vcl /etc/varnish/default.vcl
    /usr/sbin/service varnish restart
  EOH
  only_if { FileTest.exists?("/home/vcl/default.vcl") }
end

template "/etc/varnish/default.vcl" do
  source "default.vcl.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "varnish")
  not_if { FileTest.exists?("/etc/varnish/default.vcl") }
end

template "/etc/default/varnish" do
  source "etc-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "varnish")
end

template "/usr/local/sbin/cdnvcl.sh" do
  source "cdnvcl.erb"
  owner "root"
  group "root"
  mode 0700
end

template "/etc/cron.d/cdnvcl" do
  source "cdnvcl-cron.erb"
  owner "root"
  group "root"
  mode 0644
end

# varnishncsa logging daemon

bash "make /var/log/varnish readable" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    chmod 755 /var/log/varnish/
  EOH
end

service "varnishncsa" do
  service_name "varnishncsa"
  restart_command "/usr/sbin/service varnishncsa restart"
  reload_command "/usr/sbin/service varnishncsa reload"
  action :enable
end

template "/etc/default/varnishncsa" do
  source "varnishncsa-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "varnishncsa")
end

template "/etc/init.d/varnishncsa" do
  source "varnishncsa-init.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "varnishncsa")
end

directory "/var/spool/rsyslog/work" do
   mode "0775"
   owner "syslog"
   group "root"
   action :create
   recursive true
end

template "/etc/rsyslog.d/counter.conf" do
  source "counter.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end

template "/etc/rsyslog.d/varnish.conf" do
  source "varnishncsa-syslog.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end

service "nginx" do
  service_name "nginx"
  restart_command "/usr/sbin/service nginx restart"
  reload_command "/usr/sbin/service nginx reload"
  action [:enable, :start]
end

template "/etc/nginx/sites-available/default" do
  source "nginx-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nginx")
end

template "/var/www/nginx-default/index.html" do
  source "nginx.html.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/usr/local/sbin/get-vcl.sh" do
  source "get-vcl.erb"
  owner "root"
  group "root"
  mode 0755
end