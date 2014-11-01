require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module Debian
      include Chef::Mixin::ShellOut

      def base_dir
        '/usr'
      end

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

      def mysqld_bin
        '/usr/sbin/mysqld'
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def mysql_version
        new_resource.parsed_version
      end

      def mysqld_safe_bin
        '/usr/bin/mysqld_safe'
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

      def run_dir
        "/var/run/#{mysql_name}"
      end

      def socket_file
        "#{run_dir}/#{mysql_name}.sock"
      end
    end
  end
end
