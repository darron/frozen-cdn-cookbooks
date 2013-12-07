group "deploy" do
  action :create
end

template "/usr/local/sbin/add-deploy-user.sh" do
  source "add-deploy-user.erb"
  owner "root"
  group "root"
  mode "770"
end
