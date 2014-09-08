# replication
# FIXME: more words here

# master
mysql_service 'master' do
  port '3306'
  repl_acl ['127.0.0.1']
  repl_password 'danger zone'
  action :create
end

mysql_config 'master replication' do
  instance 'master'
  source 'replication.erb'
  variables(:server_id => '1', :mysql_instance => 'master')
  notifies :restart, 'mysql_service[master]'
  action :create
end

# slave-1
mysql_service 'slave-1' do
  port '3307'
  action :create
end

mysql_config 'slave-1 wat' do
  instance 'slave-1'
  source 'replication.erb'
  variables(:server_id => '2', :mysql_instance => 'slave-1')
  notifies :restart, 'mysql_service[slave-1]'
  action :create
end

# slave-2
mysql_service 'slave-2' do
  port '3308'
  action :create
end

mysql_config 'replication-slave-2' do
  instance 'slave-2'
  source 'replication.erb'
  variables(:server_id => '3', :mysql_instance => 'slave-2')
  notifies :restart, 'mysql_service[slave-1]'
  action :create
end
