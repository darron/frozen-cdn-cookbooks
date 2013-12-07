service "sshd" do
  service_name "ssh"
  supports :restart => true, :reload => true, :status => true
end

template "/etc/init.d/ssh" do
  source "ssh.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :reload, resources(:service => "sshd")
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "sshd")
end