module MysqlCookbook
  module Helpers
    module Rhel

      def scl_package?
        if node['platform_version'].to_i == 5
          return true if new_resource.parsed_version == '5.1'
          return true if new_resource.parsed_version == '5.5'
        end
        return false
      end

      def scl_name
        if node['platform_version'].to_i == 5
          return 'mysql51' if new_resource.parsed_version == '5.1'
          return 'mysql55' if new_resource.parsed_version == '5.5'
        end
        return nil
      end

      def initialize_cmd
        if scl_package?
          "scl enable #{scl_name} \"#{mysql_install_db} --datadir=#{new_resource.parsed_data_dir} --defaults-file=#{etc_dir}/my.cnf\""
        else
          "#{mysql_install_db} --datadir=#{new_resource.parsed_data_dir} --defaults-file=#{etc_dir}/my.cnf"
        end
      end

      def sysvinit_template
        if scl_package?
          "#{mysql_version}/sysvinit/#{platform_and_version}/scl-sysvinit.erb"
        else
          "#{mysql_version}/sysvinit/#{platform_and_version}/sysvinit.erb"
        end
      end

      def base_dir
        return "/opt/rh/#{scl_name}/root" if scl_package?
        return nil
      end

      def etc_dir
        "#{base_dir}/etc/#{mysql_name}"
      end

      def include_dir
        "#{etc_dir}/conf.d"
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

      def local_service_name
        return mysql_name if scl_name.nil?
        return "#{scl_name}-#{mysql_name}"
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
