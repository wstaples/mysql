require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module Debian
      include Chef::Mixin::ShellOut

      def debian_mysql_cmd
        "/usr/bin/mysql --defaults-file=/etc/#{mysql_name}/debian.cnf -e 'show databases;'"
      end

      def include_dir
        "/etc/#{mysql_name}/conf.d"
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def mysql_password_charset
        query = "SELECT CHARACTER_SET_NAME FROM information_schema.COLUMNS WHERE TABLE_NAME = 'user' AND COLUMN_NAME = 'Password';"
        try_really_hard(query, 'mysql')
      end

      def mysql_version
        new_resource.parsed_version
      end

      def mysql_w_network_stashed_pass
        "/usr/bin/mysql -u root -h 127.0.0.1 -P #{new_resource.parsed_port} -p#{Shellwords.escape(stashed_pass)}"
      end

      def mysql_w_network_stashed_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_network_stashed_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_network_resource_pass
        "/usr/bin/mysql -u root -h 127.0.0.1 -P #{new_resource.parsed_port} -p#{Shellwords.escape(new_resource.parsed_root_password)}"
      end

      def mysql_w_network_resource_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_network_resource_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :returns => [0, 1])
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
        info = shell_out!(cmd, :returns => [0, 1])
        info.exitstatus == 0 ? true : false
      end

      def mysql_w_socket_resource_pass
        "/usr/bin/mysql -S #{socket_file} -p#{Shellwords.escape(new_resource.parsed_root_password)}"
      end

      def mysql_w_socket_resource_pass_working?
        query = 'show databases;'
        cmd = "echo \"#{query}\""
        cmd << " | #{mysql_w_socket_resource_pass}"
        cmd << ' --skip-column-names'
        info = shell_out!(cmd, :returns => [0, 1])
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
        info = shell_out!(cmd, :returns => [0, 1])
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

      def try_really_hard(query, database)
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass} -D #{database} --skip-column-names")
        return info.stdout.chomp if info.exitstatus == 0
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_stashed_pass} -D #{database} --skip-column-names")
        return info.stdout.chomp if info.exitstatus == 0
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket_resource_pass} -D #{database} --skip-column-names")
        return info.stdout.chomp if info.exitstatus == 0
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket_stashed_pass} -D #{database} --skip-column-names")
        return info.stdout.chomp if info.exitstatus == 0
        info = shell_out("echo \"#{query}\" | #{mysql_w_socket} -D #{database} --skip-column-names")
        return info.stdout.chomp if info.exitstatus == 0
        false
      end

      def repair_mysql_password_charset
        query = "ALTER TABLE user CHANGE Password Password char(41) character set utf8 collate utf8_bin DEFAULT '' NOT NULL;"
        try_really_hard(query, 'mysql')
      end

      def repair_debian_password
        query = 'GRANT SELECT, INSERT, UPDATE, DELETE,'
        query << ' CREATE, DROP, RELOAD, SHUTDOWN, PROCESS,'
        query << ' FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES,'
        query << ' SUPER, CREATE TEMPORARY TABLES, LOCK TABLES,'
        query << ' EXECUTE, REPLICATION SLAVE,'
        query << " REPLICATION CLIENT ON *.* TO 'debian-sys-maint'@'localhost'"
        query << " IDENTIFIED BY '#{new_resource.parsed_debian_password}'"
        query << ' WITH GRANT OPTION;'
        try_really_hard(query, 'mysql')
      end

      def repair_root_password
        query = "UPDATE mysql.user SET Password=PASSWORD('#{new_resource.parsed_root_password}')"
        query << " WHERE User='root'; FLUSH PRIVILEGES;"
        try_really_hard(query, 'mysql')
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

      def test_debian_password
        query = 'show databases;'
        info = shell_out("echo \"#{query}\" | #{debian_mysql_cmd}")
        info.exitstatus == 0 ? true : false
      end

      def test_root_password
        cmd = '/usr/bin/mysql'
        cmd << " --defaults-file=/etc/#{mysql_name}/my.cnf"
        cmd << ' -u root'
        cmd << " -e 'show databases;'"
        cmd << " -p#{Shellwords.escape(new_resource.parsed_root_password)}"
        info = shell_out(cmd)
        info.exitstatus == 0 ? true : false
      end

      def repair_remove_test_database
        query = 'DROP DATABASE IF EXISTS test;'
        query << " DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
        return true if info.stdout.empty?
      end

      def test_remove_test_database
        query = "SHOW DATABASES LIKE 'test';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
        return true if info.stdout.empty?
      end

      def repair_remove_anonymous_users
        query = "DELETE FROM user WHERE User=''"
        try_really_hard(query, 'mysql')
      end

      def test_remove_anonymous_users
        query = "SELECT * FROM user WHERE User=''"
        try_really_hard(query, 'mysql')
      end

      def test_root_acl(acl)
        query = "SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='#{acl}';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
        return false unless info.exitstatus == 0
        return false if info.stdout.empty?
        true
      end

      def repair_root_acl(acl)
        query = " GRANT ALL PRIVILEGES ON *.* TO 'root'@'#{acl}'"
        query << " IDENTIFIED BY '#{new_resource.parsed_root_password}' WITH GRANT OPTION;"
        try_really_hard(query, 'mysql')
      end

      def test_repl_acl(acl)
        query = "SELECT Host,User,Password FROM mysql.user WHERE User='repl' AND Host='#{acl}';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
        return false unless info.exitstatus == 0
        return false if info.stdout.empty?
        true
      end

      def repair_repl_acl(acl)
        query = " GRANT REPLICATION SLAVE ON *.* TO 'repl'@'#{acl}' "
        query << " IDENTIFIED BY '#{new_resource.parsed_repl_password}';"
        try_really_hard(query, 'mysql')
      end

      def repair_repl_acl_extras
        query = "DELETE FROM mysql.user WHERE User='repl'"
        query << " AND Host NOT IN ('#{new_resource.repl_acl.join('\', \'')}');"
        try_really_hard(query, 'mysql')
      end

      def repair_root_acl_extras
        query = "DELETE FROM mysql.user WHERE User='root'"
        query << " AND Host NOT IN ('#{new_resource.root_acl.join('\', \'')}');"
        try_really_hard(query, 'mysql')
      end
      
    end
  end
end
