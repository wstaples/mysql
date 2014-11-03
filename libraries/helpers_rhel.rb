module MysqlCookbook
  module Helpers
    module Rhel

      def base_dir
        case node['platform_version'].to_i
        when 5
          case new_resource.parsed_version
          when '5.0'
            base_dir = ''
          when '5.1'
            base_dir = '/opt/rh/mysql51/root'
          when '5.5'
            base_dir = '/opt/rh/mysql55/root'
          end
        end
        base_dir
      end

      def etc_dir
        "#{base_dir}/etc/#{mysql_name}"
      end

      def include_dir
        "#{etc_dir}/conf.d"
      end

      def lc_messages_dir
        case node['platform_version'].to_i
        when 2014, 2013, 7, 6, 5
          lc_messages_dir = nil
        end
        lc_messages_dir
      end

      def mysql_bin
        "#{base_dir}/usr/bin/mysql"
      end

      def mysqld_bin
        "#{base_dir}/usr/sbin/mysqld"
      end

      def mysql_install_db
        'mysql_install_db'
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def mysql_version
        new_resource.parsed_version
      end

      def mysqld_safe_bin
        "#{base_dir}/usr/bin/mysqld_safe"
      end

      def scl_name
        "mysql55"
      end

      def local_service_name
        "#{scl_name}-#{mysql_name}"
      end

      def pid_file
        "#{run_dir}/mysql.pid"
      end

      def prefix_dir
        "#{base_dir}/usr"
      end

      def run_dir
        "#{base_dir}/var/run/#{local_service_name}"
      end

      def socket_file
        "#{run_dir}/#{local_service_name}.sock"
      end

      def platform_and_version
        case node['platform_family']
        when 'rhel'
          "rhel-#{node['platform_version'].to_i}"
        end
      end
    end
  end
end
