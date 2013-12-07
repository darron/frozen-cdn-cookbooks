#
# Cookbook Name:: base
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

case node[:platform]
when "debian", "ubuntu"
  package "curl"
  package "wget"
  package "telnet"
  package "screen"
  package "mtr"
  package "nmap"
  package "whois"
  # package "mkpasswd"
  package "traceroute"
  package "lynx-cur"
  package "command-not-found"
  package "bsd-mailx"
  package "ngrep"
  package "dnsutils"
  package "exuberant-ctags"
  package "sysstat"
  package "lsof"
  package "ftp"
  package "ufw"
  package "tree"
  package "libxslt1-dev"
  package "libxml2-dev"
  package "locate"
  package "tmux"
  package "gnutls-bin"
  gem_package "bundler"
  gem_package "capistrano"
  gem_package "capistrano-ext"
  gem_package "rake"
  gem_package "ruby-shadow"
  gem_package "fog"
else 
end

package "denyhosts"

service "denyhosts" do
  service_name "denyhosts"
  restart_command "/usr/sbin/service denyhosts restart"
  reload_command "/usr/sbin/service denyhosts reload"
  action :enable
end

template "/var/lib/denyhosts/allowed-hosts" do
  source "allowed-hosts.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "denyhosts")
end

template "/etc/denyhosts.conf" do
  source "denyhosts.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "denyhosts")
end

template "/etc/cron.daily/ntpdate" do
  source "ntpdate.erb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/default/sysstat" do
  source "sysstat.erb"
  owner "root"
  group "root"
  mode 0644
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

template "/etc/rsyslog.d/papertrail.conf" do
  source "papertrail.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end

template "/etc/rsyslog.d/dpkg.conf" do
  source "dpkg-rsyslog.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog")
end


# From: http://linuxman.wikispaces.com/Neighbour+table+overflow
template "/etc/sysctl.d/60-nto.conf" do
  source "nto.erb"
  owner "root"
  group "root"
  mode 0644
end

bash "reset sysctl" do
  cwd "/tmp"
  code <<-EOH
    /sbin/sysctl -p /etc/sysctl.d/60-nto.conf
  EOH
end

bash "update locale" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    /usr/sbin/update-locale
  EOH
end

# Register with Zerigo.

include_recipe "zerigo"

ip_address = `curl http://169.254.169.254/latest/meta-data/public-ipv4`

zerigo_record "create a record" do
  name  "#{node.name}"
  value "#{ip_address}"
  type  "A"

  zone_id               "frozencdn.net"   # Zerigo-hosted domain name
  zerigo_email          "darron@froese.org"
  zerigo_token          "not-putting-it-here-either"

  action :create
end

