#
# Cookbook Name:: redis
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

service "redis-server" do
  service_name "redis-server"
  restart_command "/usr/sbin/service redis-server restart"
  action [:start, :enable]
end

package "redis-server" do
  options "--allow-unauthenticated"
  action :install
end

gem_package "redis"

template "/etc/redis/redis.conf" do
  source "redis.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "redis-server")
end

template "/usr/share/munin/plugins/redis" do
  source "redis-munin.erb"
  owner "root"
  group "root"
  mode 0755
end

bash "Add Munin Redis plugins" do
  user "root"
  cwd "/usr/share/munin/plugins"
  code <<-EOH
    ln -s /usr/share/munin/plugins/redis /etc/munin/plugins/redis_connected_clients
    ln -s /usr/share/munin/plugins/redis /etc/munin/plugins/redis_per_sec
    ln -s /usr/share/munin/plugins/redis /etc/munin/plugins/redis_used_memory
    service munin-node restart
  EOH
  not_if { ::File.exists?("/etc/munin/plugins/redis_per_sec") }
end


# Register the new node and ip in the databag.
new_redis_node = {
  "id" => node.name,
  "ip" => node.ec2.public_ipv4
}

databag_item = Chef::DataBagItem.new
databag_item.data_bag("redis_nodes")
databag_item.raw_data = new_redis_node 
databag_item.save

# Setup firewall rules as required.
redis_nodes = []

search(:redis_nodes, '*:*') do |redis_node|
  redis_nodes << redis_node['ip']
  
  # Syslog port.
  execute redis_node['ip'] do
    command "/usr/sbin/ufw allow from #{redis_node['ip']} to any port 6379"
  end

end

