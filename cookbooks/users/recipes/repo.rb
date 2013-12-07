# TODO: 
# --
#/usr/sbin/adduser github --ingroup sysadmin  # bb33dd55
#su github
#ssh-keygen -t dsa
#cat .ssh/id_dsa.pub # Send that key to github.

#directory "/home/github/.ssh" do
#  owner "github"
#  group "sysadmin"
#  mode "0700"
#end

sysadmin_group = []
sysadmin_ssh_keys = []

search(:users, 'groups:sysadmin') do |u|
  sysadmin_group << u['id']
  sysadmin_ssh_keys << u['ssh_keys']
end

template "/home/github/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner "github"
  group "sysadmin"
  mode "600"
  variables :ssh_keys => sysadmin_ssh_keys.flatten
  action :create
end
