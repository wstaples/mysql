module MysqlCookbook
  module Helpers
    module Fedora
      def base_dir
        '/usr'
      end

      def error_log
        "/var/log/#{mysql_name}/error.log"
      end

      def etc_dir
        "/etc/#{mysql_name}"
      end

      def include_dir
        "#{etc_dir}/conf.d"
      end

      def mysql_install_db_script
        <<-EOF
        mysql_install_db --datadir=#{new_resource.parsed_data_dir} --defaults-file=#{etc_dir}/my.cnf
        EOF
      end

      def mysql_safe_init_cmd
        "#{mysqld_safe_bin} --defaults-file=#{etc_dir}/my.cnf --init-file=/tmp/#{mysql_name}/my.sql &"
      end

      def init_records_script
        <<-EOS
        set -e
        rm -rf /tmp/#{mysql_name}
        mkdir /tmp/#{mysql_name}
        cat > /tmp/#{mysql_name}/my.sql <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '#{new_resource.parsed_initial_root_password}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
FLUSH PRIVILEGES;
DROP DATABASE IF EXISTS test ;
EOSQL

       #{mysql_safe_init_cmd}
       while [ ! -f #{pid_file} ] ; do sleep 1 ; done
       kill `cat #{pid_file}`
       while [ -f #{pid_file} ] ; do sleep 1 ; done
       rm -rf /tmp/#{mysql_name}
       EOS
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

      def mysqld_bin
        '/usr/sbin/mysqld'
      end

      def mysqld_safe_bin
        '/usr/bin/mysqld_safe'
      end

      def pid_file
        "#{run_dir}/mysql.pid"
      end

      def platform_and_version
        case node['platform_family']
        when 'rhel'
          "rhel-#{node['platform_version'].to_i}"
        end
      end

      def run_dir
        "/var/run/#{mysql_name}"
      end

      def socket_file
        "#{run_dir}/mysqld.sock"
      end
    end
  end
end
