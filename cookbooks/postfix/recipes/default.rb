#
# Author:: Joshua Timberman(<joshua@opscode.com>)
# Cookbook Name:: postfix
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

package "postfix" do
  action :install
end

service "postfix" do
  action :enable
end

execute "Forward all root's email" do
  command "echo \"darron@example.com\" > /root/.forward"
  action :run
end

%w{main master}.each do |cfg|
  template "/etc/postfix/#{cfg}.cf" do
    source "#{cfg}.cf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "postfix")
  end
end

template "/usr/local/sbin/pfdel.pl" do
  source "pfdel.pl.erb"
  owner "root"
  group "sudo"
  mode 0750
end