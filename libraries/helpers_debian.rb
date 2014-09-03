require 'chef/mixin/shell_out'

module MysqlCookbook
  module Helpers
    module Debian
      include Chef::Mixin::ShellOut

      def mysql_version
        new_resource.parsed_version
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def include_dir
        "/etc/#{mysql_name}/conf.d"
      end

      def pid_file
        "#{run_dir}/#{mysql_name}.pid"
      end

      def run_dir
        "/var/run/#{mysql_name}"
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p ' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p ' + ::File.open("/etc/#{mysql_name}/.mysql_root").read.chomp if ::File.exist?("/etc/#{mysql_name}/.mysql_root")
        pass_string
      end

      # calculate platform_and_version from node attributes
      def platform_and_version
        case node['platform']
        when 'debian'
          "debian-#{node['platform_version'].to_i}"
        when 'ubuntu'
          "ubuntu-#{node['platform_version']}"
        end
      end

      def socket_file
        "#{run_dir}/#{mysql_name}.sock"
      end

      def mysql_cmd_socket
        "/usr/bin/mysql -S #{socket_file} --skip-column-names -D mysql"
      end

      def debian_mysql_cmd
        "/usr/bin/mysql --defaults-file=/etc/#{mysql_name}/debian.cnf --skip-column-names"
      end

      def alter_mysql_password_charset
        query = "ALTER TABLE user CHANGE Password Password char(41) character set utf8 collate utf8_bin DEFAULT '' NOT NULL;"
        info = shell_out("echo \"#{query}\" | #{mysql_cmd_socket}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      def mysql_password_charset
        query = "SELECT CHARACTER_SET_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME = 'user' AND COLUMN_NAME = 'Password';"
        info = shell_out("echo \"#{query}\" | #{mysql_cmd_socket}", :env => nil)
        info.stdout.chomp
      end

      def alter_debian_sys_maint
        query = "GRANT SELECT, INSERT, UPDATE, DELETE,"
        query << " CREATE, DROP, RELOAD, SHUTDOWN, PROCESS,"
        query << " FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES,"
        query << " SUPER, CREATE TEMPORARY TABLES, LOCK TABLES,"
        query << " EXECUTE, REPLICATION SLAVE,"
        query << " REPLICATION CLIENT ON *.* TO 'debian-sys-maint'@'localhost'"
        query << " IDENTIFIED BY '#{new_resource.parsed_server_debian_password}'"
        query << " WITH GRANT OPTION;"
        info = shell_out("echo \"#{query}\" | #{mysql_cmd_socket}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      def test_debian_sys_maint
        query = 'show databases;'
        info = shell_out("echo \"#{query}\" | #{debian_mysql_cmd}", :env => nil)
        info.exitstatus == 0 ? true : false
      end

      def set_root_password
        cmd = '/usr/bin/mysqladmin'
        cmd << " --defaults-file=/etc/#{mysql_name}/my.cnf"
        cmd << " -u root password #{pass_string}"
        info = shell_out(cmd, :env => nil)
        info.exitstatus == 0 ? true : false
      end

      def test_root_password
        cmd = '/usr/bin/mysql'
        cmd << " --defaults-file=/etc/#{mysql_name}/my.cnf"
        cmd << ' -u root'
        cmd << " -e 'show databases;'"
        # puts "SEANDEBUG: #{new_resource.parsed_server_root_password}"
        info = shell_out(cmd, :env => nil)
        info.exitstatus == 0 ? true : false
      end
    end
  end
end
