require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module Debian
      include Chef::Mixin::ShellOut

      def debian_mysql_cmd
        "#{mysql_bin} --defaults-file=#{etc_dir}/debian.cnf -e 'show databases;'"
      end

      def etc_dir
        "/etc/#{mysql_name}"
      end

      def include_dir
        "#{etc_dir}/conf.d"
      end

      def mysql_bin
        '/usr/bin/mysql'
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def mysql_version
        new_resource.parsed_version
      end

      def pid_file
        "#{run_dir}/#{mysql_name}.pid"
      end

      def platform_and_version
        case node['platform']
        when 'debian'
          "debian-#{node['platform_version'].to_i}"
        when 'ubuntu'
          "ubuntu-#{node['platform_version']}"
        end
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

      def run_dir
        "/var/run/#{mysql_name}"
      end

      def socket_file
        "#{run_dir}/#{mysql_name}.sock"
      end

      def test_debian_password
        query = 'show databases;'
        info = shell_out("echo \"#{query}\" | #{debian_mysql_cmd}")
        info.exitstatus == 0 ? true : false
      end
    end
  end
end
