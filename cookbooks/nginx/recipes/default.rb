#
# Cookbook Name:: nginx
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

bash "add nginx key" do
  code <<-EOH
    curl http://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-get update
  EOH
  not_if "apt-key list | grep 7BD9BF62"
end


template "nginx.list" do
  path "/etc/apt/sources.list.d/nginx.list"
  source "nginx-apt.erb"
  owner "root"
  group "root"
  mode 0644
end

package "nginx"

execute "default allow http" do
  command "/usr/sbin/ufw allow 80"
  not_if "/usr/sbin/ufw status verbose | grep '80'"
  action :run
end

monitrc "nginx"