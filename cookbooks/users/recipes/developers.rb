#
# Cookbook Name:: users
# Recipe:: developers
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

directory "/var/www/.ssh" do
  owner "www-data"
  group "www-data"
  mode "0700"
end

sysadmin_group = []
sysadmin_ssh_keys = []

search(:users, 'groups:sysadmin') do |u|
  sysadmin_group << u['id']
  sysadmin_ssh_keys << u['ssh_keys']
end

template "/var/www/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner "www-data"
  group "www-data"
  mode "644"
  variables :ssh_keys => sysadmin_ssh_keys.flatten
  action :create
end

group "www-data" do
  members sysadmin_group
end
