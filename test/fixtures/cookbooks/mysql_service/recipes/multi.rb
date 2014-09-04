# comments!

group 'alice' do
  action :create
end

user 'alice' do
  action :create
end

group 'bob' do
  action :create
end

user 'bob' do
  action :create
end

# mysql_service 'default' do
#   action :delete
# end

# hard code values where we can
mysql_service 'instance-1' do
  version node['mysql']['version']
  port '3307'
  data_dir '/data/instance-1'
  run_user 'alice'
  allow_remote_root true
  remove_anonymous_users true
  remove_test_database true
  root_network_acl ['0.0.0.0']
  server_root_password 'never gonna give you up'
  server_debian_password 'never gonna let you down'
  server_repl_password 'never_gonna_run_around_and_desert_you'
  action :create
end

# pass everything from node attributes
mysql_service 'instance-2' do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  run_user node['mysql']['run_user']
  allow_remote_root node['mysql']['allow_remote_root']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_network_acl node['mysql']['root_network_acl']
  server_root_password node['mysql']['server_root_password']
  server_debian_password node['mysql']['server_debian_password']
  server_repl_password node['mysql']['server_repl_password']
  action :create
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
