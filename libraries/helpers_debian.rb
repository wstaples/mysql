require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module Debian
      include Chef::Mixin::ShellOut

      def debian_mysql_cmd
        "/usr/bin/mysql --defaults-file=/etc/#{mysql_name}/debian.cnf --skip-column-names"
      end

      def include_dir
        "/etc/#{mysql_name}/conf.d"
      end

      def mysql_cmd_socket
        "/usr/bin/mysql -S #{socket_file} --skip-column-names -D mysql"
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      # FIXME: select method
      def mysql_password_charset
        query = "SELECT CHARACTER_SET_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME = 'user' AND COLUMN_NAME = 'Password';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket}", :env => nil)
        # puts "SEANDEBUG: echo \"#{query}\" | #{mysql_w_socket}"
        # puts "SEANDEBUG: info.stdout.chomp #{info.stdout.chomp}"
        info.stdout.chomp
      end

      def mysql_version
        new_resource.parsed_version
      end

      def mysql_w_network_stashed_pass
        "/usr/bin/mysql -u root -h localhost -p#{Shellwords.escape(stashed_pass)}"
      end

      def mysql_w_network_stashed_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_network_stashed_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :env => nil, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_network_resource_pass
        "/usr/bin/mysql -u root -h localhost -p#{Shellwords.escape(new_resource.parsed_server_root_password)}"
      end

      def mysql_w_network_resource_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_network_resource_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :env => nil, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_socket_stashed_pass
        "/usr/bin/mysql -S #{socket_file} -p#{Shellwords.escape(stashed_pass)}"
      end

      def mysql_w_socket_stashed_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_socket_stashed_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :env => nil, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_socket_resource_pass
        "/usr/bin/mysql -S #{socket_file} -p#{Shellwords.escape(new_resource.parsed_server_root_password)}"
      end

      def mysql_w_socket_resource_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_socket_resource_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :env => nil, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_socket
        "/usr/bin/mysql -S #{socket_file}"
      end

      def mysql_w_socket_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_socket}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :env => nil, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def platform_and_version
        case node['platform']
        when 'debian'
          "debian-#{node['platform_version'].to_i}"
        when 'ubuntu'
          "ubuntu-#{node['platform_version']}"
        end
      end

      def pid_file
        "#{run_dir}/#{mysql_name}.pid"
      end

      # FIXME: select method
      def repair_mysql_password_charset
        query = "ALTER TABLE user CHANGE Password Password char(41) character set utf8 collate utf8_bin DEFAULT '' NOT NULL;"
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      # FIXME: select method
      def repair_server_debian_password
        query = 'GRANT SELECT, INSERT, UPDATE, DELETE,'
        query << ' CREATE, DROP, RELOAD, SHUTDOWN, PROCESS,'
        query << ' FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES,'
        query << ' SUPER, CREATE TEMPORARY TABLES, LOCK TABLES,'
        query << ' EXECUTE, REPLICATION SLAVE,'
        query << " REPLICATION CLIENT ON *.* TO 'debian-sys-maint'@'localhost'"
        query << " IDENTIFIED BY '#{new_resource.parsed_server_debian_password}'"
        query << ' WITH GRANT OPTION;'
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      def repair_server_root_password
        query = "UPDATE mysql.user SET Password=PASSWORD('#{new_resource.parsed_server_root_password}')"
        query << " WHERE User='root'; FLUSH PRIVILEGES;"
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket}", :env => nil)
        info.stdout.chomp
        info.exitstatus == 0 ? true : false
      end

      def run_dir
        "/var/run/#{mysql_name}"
      end

      def socket_file
        "#{run_dir}/#{mysql_name}.sock"
      end

      def stashed_pass
        return ::File.open("/etc/#{mysql_name}/.mysql_root").read.chomp if ::File.exist?("/etc/#{mysql_name}/.mysql_root")
        ''
      end

      def test_server_debian_password
        query = 'show databases;'
        info = shell_out("echo \"#{query}\" | #{debian_mysql_cmd}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      # FIXME: select method
      def test_server_root_password
        cmd = '/usr/bin/mysql'
        cmd << " --defaults-file=/etc/#{mysql_name}/my.cnf"
        cmd << ' -u root'
        cmd << " -e 'show databases;'"
        puts "SEANDEBUG: #{new_resource.parsed_server_root_password}"
        info = shell_out(cmd, :env => nil)
        info.exitstatus == 0 ? true : false
      end
    end
  end
end
