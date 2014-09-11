# replication
# FIXME: more words here

# master
mysql_config 'master replication' do
  instance 'master'
  source 'replication-master.erb'
  variables(:server_id => '1', :mysql_instance => 'master')
  notifies :restart, 'mysql_service[master]'
  notifies :run, 'bash[populate databass]', :delayed
  action :create
end

mysql_service 'master' do
  port '3306'
  repl_acl ['127.0.0.1']
  repl_password 'danger zone'
  action :create
  notifies :run, 'bash[create /root/dump.sql]', :immediately
  notifies :run, 'bash[stash position in /root/position]', :immediately
end

# factor me into ruby_block?
bash 'create /root/dump.sql' do
  user 'root'
  code <<-EOF
    mysqldump --defaults-file=/etc/mysql-master/my.cnf \
    -u root -pilikerandompasswords \
    --skip-lock-tables --single-transaction \
    --flush-logs --hex-blob --master-data=2 -A \
    > /root/dump.sql;
   EOF
  creates '/root/dump.sql'
  notifies :run, 'bash[stash position in /root/position]'
  action :nothing
end

bash 'stash position in /root/position' do
  user 'root'
  code <<-EOF
    head /root/dump.sql -n80 \
    | grep 'MASTER_LOG_POS' \
    | awk '{ print $6 }' \
    | cut -f2 -d '=' \
    | cut -f1 -d';' \
    > /root/position
  EOF
  action :nothing
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
  notifies :run, 'execute[slave-1 import]', :immediately
  notifies :run, 'ruby_block[start_slave_1]', :immediately
  action :create
end

execute 'slave-1 import' do
  user 'root'
  command '/usr/bin/mysql -u root -h 127.0.0.1 -P 3307 -pilikerandompasswords < /root/dump.sql'
  action :nothing
end

ruby_block 'start_slave_1' do
  block { start_slave_1 }
  action :nothing
end

# slave-2
mysql_config 'replication-slave-2' do
  instance 'slave-2'
  source 'replication-slave.erb'
  variables(:server_id => '3', :mysql_instance => 'slave-2')
  notifies :restart, 'mysql_service[slave-2]'
  action :create
end

mysql_service 'slave-2' do
  port '3308'
  notifies :run, 'execute[slave-2 import]', :immediately
  notifies :run, 'ruby_block[start_slave_2]', :immediately
  action :create
end

execute 'slave-2 import' do
  user 'root'
  command '/usr/bin/mysql -u root -h 127.0.0.1 -P 3308 -pilikerandompasswords < /root/dump.sql'
  action :nothing
end

ruby_block 'start_slave_2' do
  block { start_slave_2 }
  action :nothing
end

# Put some data in the master
bash 'populate databass' do
  code <<-EOF
  echo "CREATE DATABASE databass;" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pilikerandompasswords
  echo "CREATE TABLE databass.table1 (name VARCHAR(20), rank VARCHAR(20));" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pilikerandompasswords
  echo "INSERT INTO databass.table1 (name,rank) VALUES('captain','awesome');" | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pilikerandompasswords
  EOF
  action :nothing
end
