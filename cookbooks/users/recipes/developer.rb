#
# Cookbook Name:: users
# Recipe:: developer
#

developer_group = []

search(:users, 'groups:developer') do |u|
  developer_group << u['id']

  home_dir = "/home/#{u['id']}"

  user u['id'] do
    shell u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['id']
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['id']
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end

group "developer" do
  gid 2302
  members developer_group
end