service "ufw" do
  service_name "ufw"
  start_command "/usr/sbin/ufw enable"
  stop_command "/usr/sbin/ufw disable"
  status_command "/usr/sbin/ufw status verbose"
  supports value_for_platform(
    "ubuntu" => { "default" => [ :start, :stop, :status ] }
  )
  action :enable
end

template "ufw.conf" do
  path "/etc/ufw/ufw.conf"
  source "ufw.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :start, resources(:service => "ufw")
end

execute "default deny incoming" do
  command "/usr/sbin/ufw default deny incoming"
  not_if "/usr/sbin/ufw status verbose | grep 'Default\: deny \(incoming\)'"
  action :run
end

execute "default allow outgoing" do
  command "/usr/sbin/ufw default allow outgoing"
  not_if "/usr/sbin/ufw status verbose | grep 'Default\:.* allow \(outgoing\)'"
  action :run
end

execute "default allow ssh" do
  command "/usr/sbin/ufw allow 22"
  not_if "/usr/sbin/ufw status verbose | grep '22'"
  action :run
end

execute "default allow munin" do
  command "/usr/sbin/ufw allow 4949"
  not_if "/usr/sbin/ufw status verbose | grep '4949'"
  action :run
end