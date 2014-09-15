module MysqlCookbook
  module Helpers
    module OmniOS
      def base_dir
        "/opt/mysql#{pkg_ver_string}"
      end

      def mysql_name
        "mysql-#{new_resource.parsed_instance}"
      end

      def include_dir
        "/opt/mysql#{pkg_ver_string}/etc/#{mysql_name}/conf.d"
      end

      def my_cnf
        "#{base_dir}/etc/#{mysql_name}/my.cnf"
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
      
      # FIXME: refactor into common lib
      def test_root_password
        cmd = '/opt/mysql55/bin/mysql' # make variable
        cmd << " --defaults-file=/etc/#{mysql_name}/my.cnf" # make variable
        cmd << ' -u root' # make variable #{admin_user}
        cmd << " -e 'show databases;'"
        cmd << " -p#{Shellwords.escape(new_resource.parsed_root_password)}"
        info = shell_out(cmd)
        info.exitstatus == 0 ? true : false
      end
      
      def mysql_w_network_resource_pass
        "/usr/bin/mysql -u root -h 127.0.0.1 -P #{new_resource.parsed_port} -p#{Shellwords.escape(new_resource.parsed_root_password)}"
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
      
    end
  end
end
