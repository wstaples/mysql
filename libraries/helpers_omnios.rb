require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module OmniOS
      include Chef::Mixin::ShellOut

      def base_dir
        "/opt/mysql#{pkg_ver_string}"
      end

      def etc_dir
        "#{base_dir}/etc/#{mysql_name}/"
      end

      def include_dir
        "/opt/mysql#{pkg_ver_string}/etc/#{mysql_name}/conf.d"
      end

      def my_cnf
        "#{base_dir}/etc/#{mysql_name}/my.cnf"
      end

      def mysql_bin
        "#{base_dir}/bin/mysql"
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def pid_file
        "/var/run/#{mysql_name}/mysql.pid"
      end

      def pkg_ver_string
        new_resource.parsed_version.gsub('.', '')
      end

      def prefix_dir
        "/opt/mysql#{pkg_ver_string}"
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
