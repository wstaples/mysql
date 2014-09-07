# replication

mysql_service 'master' do
  port '3306'
  repl_acl ['127.0.0.1']
  repl_password 'never gonna let you down'
  action :create
  provider Chef::Provider::MysqlService::Debian
end

# FIXME: notify broken?
mysql_config 'replication' do
  instance 'master'
  source 'replication.erb'
  variables(
    :server_id => '1',
    :log_bin => '/var/log/mysql-master/mysql-bin.log',
    :binlog_do_db => 'databass'
    )
  notifies :restart, 'mysql_service[master]'
  action :create
end

mysql_service 'slave-1' do
  port '3307'
  action :create
end

mysql_service 'slave-2' do
  port '3308'
  action :create
end
