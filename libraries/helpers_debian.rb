module MysqlCookbook
  module Helpers
    module Debian
      def mysql_version
        mysql_version = new_resource.parsed_version
        mysql_version
      end

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
        pid_file = "#{run_dir}/#{mysqld_name}.pid"
        pid_file
      end

      def run_dir
        run_dir = "/var/run/#{mysqld_name}"
        run_dir
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p ' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p' + ::File.open("/etc/#{mysql_name}/.mysql_root").read.chomp if ::File.exist?("/etc/#{mysql_name}/.mysql_root")
        pass_string
      end

      # calculate platform_and_version from node attributes
      def platform_and_version
        case node['platform']
        when 'debian'
          platform_and_version = "debian-#{node['platform_version'].to_i}"
        when 'ubuntu'
          platform_and_version = "ubuntu-#{node['platform_version']}"
        end
        platform_and_version
      end

      def socket_file
        socket_file = "/var/run/#{mysqld_name}/#{mysqld_name}.sock"
        socket_file
      end
    end
  end
end
