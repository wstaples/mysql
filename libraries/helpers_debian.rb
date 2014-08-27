module MysqlCookbook
  module Helpers
    module Debian
      def mysql_name
        new_resource.parsed_instance == 'default' ? mysql_name = 'mysql' : mysql_name = "mysql-#{new_resource.parsed_instance}"
        mysql_name
      end

      def mysqld_name
        new_resource.parsed_instance == 'default' ? mysql_name = 'mysqld' : mysql_name = "mysqld-#{new_resource.parsed_instance}"
        mysql_name
      end

      def include_dir
        include_dir = "/etc/#{mysql_name}/conf.d"
        include_dir
      end

      def pid_file
        pid_file = "/var/run/mysqld/#{mysqld_name}.pid"
        pid_file
      end

      def run_dir
        run_dir = '/var/run/mysqld'
        run_dir
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p ' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p' + ::File.open("/etc/.#{mysql_name}_root").read.chomp if ::File.exist?("/etc/.#{mysql_name}_root")
        pass_string
      end

      def socket_file
        socket_file = "/var/run/mysqld/#{mysqld_name}.sock"
        socket_file
      end
    end
  end
end
