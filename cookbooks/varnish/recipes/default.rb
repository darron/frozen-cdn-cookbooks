#
# Cookbook Name:: varnish
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

# This should only fire once - before the very first install of varnish.
# that way, we can get a good copy of the current working varnish config
# on the first run.
bash "grab first varnish config" do
  cwd "/home/vcl"
  user "vcl"
  code <<-EOH
    curl -O http://app.example.net/vcl
    mv vcl default.vcl
  EOH
  not_if { FileTest.exists?("/etc/varnish/default.vcl") }
end

template "varnish.list" do
  path "/etc/apt/sources.list.d/varnish.list"
  source "varnish.list.erb"
  owner "root"
  group "root"
  mode 0644
end

bash "add_varnish_apt_key_and_update" do
  code <<-EOH
    curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -
    apt-get update
  EOH
  not_if "apt-key list | grep C4DEFFEB"
end

package "varnish"

execute "default allow http" do
  command "/usr/sbin/ufw allow 80"
  not_if "/usr/sbin/ufw status verbose | grep '80'"
  action :run
end

bash "install_plugins" do
  user "root"
  cwd "/usr/share/munin/plugins"
  code <<-EOH
  git clone git://github.com/basiszwo/munin-varnish.git
  chmod a+x /usr/share/munin/plugins/munin-varnish/varnish_*
  ln -s /usr/share/munin/plugins/munin-varnish/varnish_* /etc/munin/plugins/
  echo "" >> /etc/munin/plugin-conf.d/munin-node
  echo "[varnish*]" >> /etc/munin/plugin-conf.d/munin-node
  echo "user root" >> /etc/munin/plugin-conf.d/munin-node
  service munin-node restart
  EOH
  not_if { FileTest.exists?("/usr/share/munin/plugins/munin-varnish") }
end

monitrc "varnish"