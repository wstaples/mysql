# comments!

group 'alice' do
  action :create
end

user 'alice' do
  gid 'alice'
  action :create
end

group 'bob' do
  action :create
end

user 'bob' do
  gid 'bob'
  action :create
end

mysql_service 'default' do
  action :delete
end

# hard code values where we can
mysql_service 'instance-1' do
  version node['mysql']['version']
  port '3307'
  data_dir '/data/instance-1'
  run_user 'alice'
  action [:create, :start]
end

# pass everything from node attributes
mysql_service 'instance-2' do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  run_user node['mysql']['run_user']
  action [:create, :start]
end

# log 'notify restart' do
#   level :info
#   action :write
#   notifies :restart, 'mysql_service[instance-1]'
# end

# log 'notify reload' do
#   level :info
#   action :write
#   notifies :reload, 'mysql_service[instance-2]'
# end
