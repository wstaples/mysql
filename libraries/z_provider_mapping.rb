# provider mappings

## Debian
# client
Chef::Platform.set :platform => :debian, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Debian
Chef::Platform.set :platform => :centos, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel

# service
Chef::Platform.set :platform => :debian, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Debian
Chef::Platform.set :platform => :centos, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Rhel
Chef::Platform.set :platform => :omnios, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Omnios

# config
Chef::Platform.set :platform => :debian, :resource => :mysql_config, :provider => Chef::Provider::MysqlConfig::Debian
Chef::Platform.set :platform => :centos, :resource => :mysql_config, :provider => Chef::Provider::MysqlConfig::Rhel
Chef::Platform.set :platform => :omnios, :resource => :mysql_config, :provider => Chef::Provider::MysqlConfig::Omnios
