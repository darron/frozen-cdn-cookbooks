#
# Cookbook Name:: app
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

package "libmysqlclient-dev"

# Bundler 1.1 is way better than 1.0 when it comes to installing gems.
bash "update bundler" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    gem install bundler --pre
  EOH
  not_if { FileTest.exists?("/usr/local/lib/ruby/gems/1.9.1/gems/bundler-1.1.rc.7/") }
end

# App server is started this way.
# cd /home/app/app/current; bundle exec unicorn_rails -c unicorn.rb -D -E production

service "nginx" do
  service_name "nginx"
  supports :restart => true, :reload => true, :status => true
end

template "/etc/init.d/nginx" do
  source "nginx.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :reload, resources(:service => "nginx")
end