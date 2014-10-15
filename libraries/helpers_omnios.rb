require 'chef/mixin/shell_out'
require 'shellwords'

module MysqlCookbook
  module Helpers
    module OmniOS
      include Chef::Mixin::ShellOut
      
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

      
      # FIXME make dynamic for 55 vs v56
      # WHOLE GROUP HERE
      def mysql_w_network_resource_pass
        "/opt/mysql55/bin/mysql -u root -h 127.0.0.1 -P #{new_resource.parsed_port} -p#{Shellwords.escape(new_resource.parsed_root_password)}"
      end

      def mysql_w_network_stashed_pass
        "/opt/mysql55/bin/mysql -u root -h 127.0.0.1 -P #{new_resource.parsed_port} -p#{Shellwords.escape(stashed_pass)}"
      end
      
      def mysql_w_socket_resource_pass
        "/opt/mysql55/bin/mysql -S #{socket_file} -p#{Shellwords.escape(new_resource.parsed_root_password)}"
      end
      
      def mysql_w_socket_stashed_pass
        "/opt/mysql55/bin/mysql -S #{socket_file} -p#{Shellwords.escape(stashed_pass)}"
      end

      def mysql_w_socket
        "/opt/mysql55/bin/mysql -S #{socket_file}"
      end

      
      # FIXME: refactor into common lib
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

      # FIXME: refactor into common lib
      def repair_root_password
        query = "UPDATE mysql.user SET Password=PASSWORD('#{new_resource.parsed_root_password}')"
        query << " WHERE User='root'; FLUSH PRIVILEGES;"
        try_really_hard(query, 'mysql')
      end

      # FIXME: uh... wat? should this be coupled to another method?      
      def stashed_pass
        return ::File.open("#{base_dir}/etc/#{mysql_name}/.mysql_root").read.chomp if ::File.exist?("#{base_dir}/etc/#{mysql_name}/.mysql_root")
        ''
      end

      ####
      # END SET_ROOT_PASSWORD
      ####

      # FIXME: refactor into common lib
      def test_remove_anonymous_users
        query = "SELECT * FROM user WHERE User=''"
        try_really_hard(query, 'mysql')
      end
      
      # FIXME: refactor into common lib
      def repair_remove_anonymous_users
        query = "DELETE FROM user WHERE User=''"
        try_really_hard(query, 'mysql')
      end      

      # FIXME: refactor into common lib
      def test_repl_acl(acl)
        query = "SELECT Host,User,Password FROM mysql.user WHERE User='repl' AND Host='#{acl}';"
        info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
        return false unless info.exitstatus == 0
        return false if info.stdout.empty?
        true
      end

      # FIXME: refactor into common lib
      def repair_repl_acl(acl)
        query = " GRANT REPLICATION SLAVE ON *.* TO 'repl'@'#{acl}' "
        query << " IDENTIFIED BY '#{new_resource.parsed_repl_password}';"
        try_really_hard(query, 'mysql')
      end

      # FIXME: refactor into common lib
      def repair_repl_acl_extras
        query = "DELETE FROM mysql.user WHERE User='repl'"
        query << " AND Host NOT IN ('#{new_resource.repl_acl.join('\', \'')}');"
        try_really_hard(query, 'mysql')
      end
      
      # FIXME: refactor into common lib
      def repair_root_acl_extras
        query = "DELETE FROM mysql.user WHERE User='root'"
        query << " AND Host NOT IN ('#{new_resource.root_acl.join('\', \'')}');"
        try_really_hard(query, 'mysql')
      end
      
    end
  end
end
