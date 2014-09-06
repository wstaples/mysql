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

# mysql_service 'default' do
#   action :delete
# end

# hard code values where we can
mysql_service 'instance-1' do
  version node['mysql']['version']
  port '3307'
  data_dir '/data/instance-1'
  run_user 'alice'
  remove_anonymous_users true
  remove_test_database true
  root_acl ['%']
  root_password 'never gonna give you up'
  repl_acl nil
  repl_password 'never gonna let you down'
  debian_password 'never gonna run around and desert you'
  action :create
end

# pass everything from node attributes
mysql_service 'instance-2' do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  run_user node['mysql']['run_user']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_password node['mysql']['root_password']
  root_acl node['mysql']['root_acl']
  repl_password node['mysql']['repl_password']
  repl_acl node['mysql']['repl_acl']
  debian_password node['mysql']['server_debian_password']
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
