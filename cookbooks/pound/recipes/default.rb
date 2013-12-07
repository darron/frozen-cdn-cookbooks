#
# Cookbook Name:: pound
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
package "pound"

execute "default allow https" do
  command "/usr/sbin/ufw allow 443"
  not_if "/usr/sbin/ufw status verbose | grep '443'"
  action :run
end

template "/etc/pound/pound.cfg" do
  source "pound.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/pound/cdn.crt" do
  source "cdn.erb"
  owner "root"
  group "root"
  mode 0644
end

template "/etc/default/pound" do
  source "default.erb"
  owner "root"
  group "root"
  mode 0644
end

service "pound" do
  service_name "pound"
  restart_command "/usr/sbin/service pound restart"
  reload_command "/usr/sbin/service pound reload"
  action [:enable, :start]
end

monitrc "pound"