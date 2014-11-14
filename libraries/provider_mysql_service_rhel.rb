require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers_rhel'

class Chef
  class Provider
    class MysqlService
      class Rhel < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include MysqlCookbook::Helpers::Rhel

        action :create do
          # we need to enable the yum-mysql-community repository to get packages
          case new_resource.parsed_version
          when '5.5'
            # Prefer 5.5 from SCL
            unless node['platform_version'].to_i == 5
              recipe_eval do
                run_context.include_recipe 'yum-mysql-community::mysql55'
              end
            end
          when '5.6'
            recipe_eval do
              run_context.include_recipe 'yum-mysql-community::mysql56'
            end
          when '5.7'
            recipe_eval do
              run_context.include_recipe 'yum-mysql-community::mysql57'
            end
          end

          # Software installation
          package "#{new_resource.parsed_name} :create #{new_resource.parsed_package_name}" do
            package_name new_resource.parsed_package_name
            version new_resource.parsed_package_version
            action new_resource.parsed_package_action
          end

          # System users
          group "#{new_resource.parsed_name} :create mysql" do
            group_name 'mysql'
            action :create
          end

          user "#{new_resource.parsed_name} :create mysql" do
            username 'mysql'
            gid 'mysql'
            action :create
          end

          # Turns out that mysqld is hard coded to try and read
          # /etc/mysql/my.cnf, and its presence causes problems when
          # setting up multiple services.
          file "#{new_resource.parsed_name} :create #{base_dir}/etc/mysql/my.cnf" do
            path "#{base_dir}/etc/mysql/my.cnf"
            action :delete
          end

          file "#{new_resource.parsed_name} :create #{base_dir}/etc/my.cnf" do
            path "#{base_dir}/etc/my.cnf"
            action :delete
          end

          # Support directories
          directory "#{new_resource.parsed_name} :create #{etc_dir}" do
            path "#{etc_dir}"
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

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

          directory "#{new_resource.parsed_name} :create #{new_resource.parsed_data_dir}" do
            path new_resource.parsed_data_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          directory "#{new_resource.parsed_name} :create #{base_dir}/var/log/#{local_service_name}" do
            path "#{base_dir}/var/log/#{local_service_name}"
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          # FIXME: pass new_resource as config
          template "#{new_resource.parsed_name} :create #{etc_dir}/my.cnf" do
            path "#{etc_dir}/my.cnf"
            source "#{new_resource.parsed_version}/my.cnf.erb"
            cookbook 'mysql'
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0600'
            variables(
              :run_user => new_resource.parsed_run_user,
              :data_dir => new_resource.parsed_data_dir,
              :pid_file => pid_file,
              :socket_file => socket_file,
              :port => new_resource.parsed_port,
              :include_dir => include_dir
              )
            action :create
          end

          # initialize mysql database
          bash "#{new_resource.parsed_name} :create initialize mysql database" do
            cwd new_resource.parsed_data_dir
            code mysql_install_db_script
            not_if "/usr/bin/test -f #{new_resource.parsed_data_dir}/mysql/user.frm"
            # notifies :run, "bash[#{new_resource.parsed_name} :create initial records]"
            action :run
          end

          bash "#{new_resource.parsed_name} :create initial records" do
            code init_records_script
            action :nothing
          end

        end

        action :delete do
        end

        action :start do
          template "#{new_resource.parsed_name} :start /etc/init.d/#{mysql_name}" do
            path "/etc/init.d/#{mysql_name}"
            source sysvinit_template
            owner 'root'
            group 'root'
            mode '0755'
            variables(
              :base_dir => base_dir,
              :data_dir => new_resource.parsed_data_dir,
              :etc_dir => etc_dir,
              :error_log => error_log,
              :local_service_name => local_service_name,
              :mysqld_safe_bin => mysqld_safe_bin,
              :pid_file => pid_file,
              :port => new_resource.parsed_port,
              :run_user => new_resource.parsed_run_user,
              :scl_name => scl_name,
              :socket_file => socket_file
              )
            cookbook 'mysql'
            action :create
          end

          service "#{new_resource.parsed_name} :start #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Init
            supports :restart => true, :status => true
            action [:start]
          end
        end

        action :stop do
        end

        action :restart do
        end

        action :reload do
        end
      end
    end
  end
end
