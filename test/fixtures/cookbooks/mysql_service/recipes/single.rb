# comments!

mysql_service node['mysql']['service_name'] do
  version node['mysql']['version']
  port node['mysql']['port']
  data_dir node['mysql']['data_dir']
  run_user node['mysql']['run_user']
  remove_anonymous_users node['mysql']['remove_anonymous_users']
  remove_test_database node['mysql']['remove_test_database']
  root_acl node['mysql']['root_acl']
  root_password node['mysql']['root_password']
  repl_acl node['mysql']['repl_acl']
  repl_password node['mysql']['repl_password']
  debian_password node['mysql']['debian_password']
  action :create
end
