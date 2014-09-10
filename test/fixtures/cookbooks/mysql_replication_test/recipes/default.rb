# replication
# FIXME: more words here

# master
mysql_config 'master replication' do
  instance 'master'
  source 'replication-master.erb'
  variables(:server_id => '1', :mysql_instance => 'master')
  notifies :restart, 'mysql_service[master]'
  action :create
end

mysql_service 'master' do
  port '3306'
  repl_acl ['127.0.0.1']
  repl_password 'danger zone'
  action :create
  notifies :run, 'bash[dump master]'
end

bash 'dump master' do
  user 'root'
  code <<-EOF
    mysqldump --defaults-file=/etc/mysql-master/my.cnf \
    -u root \
    -pilikerandompasswords \
    --skip-lock-tables \
    --single-transaction \
    --flush-logs \
    --hex-blob \
    --master-data=2 \
    -A \
    > /root/dump.sql;
    head /root/dump.sql -n80 \
    | grep 'MASTER_LOG_POS' \
    | awk '{ print $6}' \
    | cut -f2 -d '=' \
    | cut -f1 -d';' \
    > /root/pos
  EOF
  action :run
end

# slave-1
mysql_config 'replication-slave-1' do
  instance 'slave-1'
  source 'replication-slave.erb'
  variables(:server_id => '2', :mysql_instance => 'slave-1')
  notifies :restart, 'mysql_service[slave-1]'
  action :create
end

mysql_service 'slave-1' do
  port '3307'
  action :create
end

ruby_block 'start_slave_1' do
  block { start_slave_1 }
  action :run
end

# slave-2
mysql_config 'replication-slave-2' do
  instance 'slave-2'
  source 'replication-slave.erb'
  variables(:server_id => '3', :mysql_instance => 'slave-2')
  notifies :restart, 'mysql_service[slave-1]'
  action :create
end

mysql_service 'slave-2' do
  port '3308'
  action :create
end
