service "redis-server" do
  service_name "redis-server"
  restart_command "/usr/sbin/service redis-server restart"
  action [:start, :enable]
end

template "/etc/redis/redis.conf" do
  source "redis-counter.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, resources(:service => "redis-server")
end