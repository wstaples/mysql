require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers_omnios'

class Chef
  class Provider
    class MysqlService
      class Omnios < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include MysqlCookbook::Helpers
        include MysqlCookbook::Helpers::OmniOS

        action :create do
          package "#{new_resource.parsed_name} :create mysql" do
            package_name new_resource.parsed_package_name
            action :install
          end

          # support directories
          directory "#{new_resource.parsed_name} :create #{include_dir}" do
            path include_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          directory "#{new_resource.parsed_name} :create #{run_dir}" do
            path run_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0755'
            recursive true
            action :create
          end

          directory "#{new_resource.parsed_name} :create /var/adm/log/#{mysql_name}" do
            path "/var/adm/log/#{mysql_name}"
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0755'
            recursive true
            action :create
          end

          # data_dir
          directory "#{new_resource.parsed_name} :create #{new_resource.parsed_data_dir}" do
            path new_resource.parsed_data_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          template "#{new_resource.parsed_name} :create #{my_cnf}" do
            path my_cnf
            source "#{new_resource.parsed_version}/my.cnf.erb"
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0600'
            variables(
              :base_dir => base_dir,
              :include_dir => include_dir,
              :data_dir => new_resource.parsed_data_dir,
              :pid_file => pid_file,
              :socket_file => socket_file,
              :port => new_resource.parsed_port,
              :lc_messages_dir => "#{base_dir}/share"
              )
            cookbook 'mysql'
            notifies :restart, "service[#{new_resource.parsed_name} :create #{mysql_name}]"
            action :create
          end

          # initialize mysql database
          bash "#{new_resource.parsed_name} :create initialize mysql database" do
            user new_resource.parsed_run_user
            cwd new_resource.parsed_data_dir
            code <<-EOF
              #{prefix_dir}/scripts/mysql_install_db \
                --basedir=#{base_dir} \
                --defaults-file=#{my_cnf} \
                --datadir=#{new_resource.parsed_data_dir} \
                --user=#{new_resource.parsed_run_user}
              EOF
            not_if "/usr/bin/test -f #{new_resource.parsed_data_dir}/mysql/user.frm"
          end

          template "#{new_resource.parsed_name} :create /lib/svc/method/#{mysql_name}" do
            path "/lib/svc/method/#{mysql_name}"
            cookbook 'mysql'
            source 'omnios/svc.method.mysqld.erb'
            cookbook 'mysql'
            owner 'root'
            group 'root'
            mode '0555'
            variables(
              :data_dir => new_resource.parsed_data_dir,
              :run_user => new_resource.parsed_run_user,
              :base_dir => base_dir,
              :pid_file => pid_file,
              :my_cnf => my_cnf,
              :mysql_name => mysql_name
              )
            action :create
          end

          smf "#{new_resource.parsed_name} :create #{mysql_name}" do
            name mysql_name
            user new_resource.parsed_run_user
            group new_resource.parsed_run_group
            start_command "/lib/svc/method/#{mysql_name} start"
          end

          service "#{new_resource.parsed_name} :create #{mysql_name}" do
            service_name mysql_name
            supports :restart => true
            action [:start, :enable]
          end

          # set root password
          ruby_block "#{new_resource.parsed_name} :create repair_root_password" do
            block { repair_root_password }
            not_if { test_root_password }
            action :run
            notifies :create, "file[#{new_resource.parsed_name} :create #{etc_dir}/.mysql_root]"
          end

          file "#{new_resource.parsed_name} :create #{etc_dir}/.mysql_root" do
            path "#{etc_dir}/.mysql_root"
            mode '0600'
            content new_resource.parsed_root_password
            action :nothing
          end

          # remove anonymous_users
          ruby_block "#{new_resource.parsed_name} :create repair_remove_anonymous_users" do
            block { repair_remove_anonymous_users }
            not_if { test_remove_anonymous_users }
            only_if { new_resource.parsed_remove_anonymous_users }
            action :run
          end

          # repair repl ACL
          new_resource.repl_acl.each do |acl|
            ruby_block "#{new_resource.parsed_name} :create repl_acl #{acl}" do
              block { repair_repl_acl acl }
              not_if { test_repl_acl acl }
              notifies :run, "ruby_block[#{new_resource.parsed_name} :create repl_acl_extras]"
              action :run
            end
          end

          ruby_block "#{new_resource.parsed_name} :create repl_acl_extras" do
            block { repair_repl_acl_extras }
            action :nothing
          end

          # repair root ACL
          new_resource.root_acl.each do |acl|
            ruby_block "#{new_resource.parsed_name} :create root_acl #{acl}" do
              block { repair_root_acl acl }
              not_if { test_root_acl acl }
              notifies :run, "ruby_block[#{new_resource.parsed_name} :create root_acl_extras]"
              action :run
            end
          end

          ruby_block "#{new_resource.parsed_name} :create root_acl_extras" do
            block { repair_root_acl_extras }
            action :nothing
          end
        end

        action :delete do
          service "#{new_resource.parsed_name} :create #{mysql_name}" do
            service_name mysql_name
            action [:stop]
          end
        end

        action :restart do
          service "#{new_resource.parsed_name} :create #{mysql_name}" do
            service_name mysql_name
            supports :restart => true
            action :restart
          end
        end

        action :reload do
          service "#{new_resource.parsed_name} :create #{mysql_name}" do
            service_name mysql_name
            supports :reload => true
            action :reload
          end
        end
      end
    end
  end
end
