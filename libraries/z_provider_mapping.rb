# provider mappings

# client
Chef::Platform.set :platform => :debian, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Debian

# service
Chef::Platform.set :platform => :debian, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Debian
Chef::Platform.set :platform => :omnios, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Omnios

# config
Chef::Platform.set :platform => :debian, :resource => :mysql_config, :provider => Chef::Provider::MysqlConfig::Debian
