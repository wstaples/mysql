require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def start_slave_1
  query = " CHANGE MASTER TO"
  query << " MASTER_HOST='127.0.0.1',"
  query << " MASTER_USER='repl',"
  query << " MASTER_PASSWORD='danger zone',"
  query << " MASTER_PORT=3306,"
  query << " MASTER_LOG_POS=#{::File.open('/root/pos').read.chomp};"
  query << " START SLAVE;"
  puts "SEANDEBUG: #{query}"
  # info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
  info = shell_out("echo \"#{query}\" | /usr/bin/mysql -u root -h 127.0.0.1 -P3307 -pilikerandompasswords")
end
