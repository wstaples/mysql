module Mysql
  module Helpers
    module Debian
      def mysql_version
        new_resource.parsed_version
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def mysqld_name
        new_resource.parsed_instance == 'default' ? 'mysqld' : "mysqld-#{new_resource.parsed_instance}"
      end

      def include_dir
        "/etc/#{mysql_name}/conf.d"
      end

      def pid_file
        "#{run_dir}/#{mysqld_name}.pid"
      end

      def run_dir
        "/var/run/#{mysqld_name}"
      end

      def pass_string
        if new_resource.parsed_server_root_password.empty?
          pass_string = ''
        else
          pass_string = '-p' + Shellwords.escape(new_resource.parsed_server_root_password)
        end

        pass_string = '-p' + ::File.open("/etc/#{mysql_name}/.mysql_root").read.chomp if ::File.exist?("/etc/#{mysql_name}/.mysql_root")
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
        "/var/run/#{mysqld_name}/#{mysqld_name}.sock"
      end
    end
  end
end
