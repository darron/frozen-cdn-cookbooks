#
# Cookbook Name:: syslog_server
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

# execute "default allow syslog" do
#   command "/usr/sbin/ufw allow 514"
#   not_if "/usr/sbin/ufw status verbose | grep '514'"
#   action :run
# end

# Setup firewall rules as required.
varnish_nodes = []

search(:varnish_nodes, '*:*') do |varnish_node|
  varnish_nodes << varnish_node['ip']
  
  # Syslog port.
  execute varnish_node['ip'] do
    command "/usr/sbin/ufw allow from #{varnish_node['ip']} to any port 514"
  end

end

service "rsyslog" do
  service_name "rsyslog"
  restart_command "/usr/sbin/service rsyslog restart"
  action :start
end

template "/etc/rsyslog.conf" do
  source "rsyslog.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end

template "/etc/rsyslog.d/50-default.conf" do
  source "rsyslog-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end

template "/etc/logrotate.d/counter" do
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/var/log/counter" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if { FileTest.exists?("/var/log/counter/") }
end

bash "create original counter log file" do
  cwd "/tmp"
  code <<-EOH
    touch /var/log/counter/traffic.log
    chmod 644 /var/log/counter/traffic.log
    chown syslog.adm /var/log/counter/traffic.log
  EOH
  not_if { FileTest.exists?("/var/log/counter/traffic.log") }
end

bash "proper counter log file permissions" do
  cwd "/tmp"
  code <<-EOH
    chmod 644 /var/log/counter/traffic.log
  EOH
  only_if { FileTest.exists?("/var/log/counter/traffic.log") }
end