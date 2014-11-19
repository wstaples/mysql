require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers_fedora'

class Chef
  class Provider
    class MysqlService
      class Fedora < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include MysqlCookbook::Helpers::Fedora

        action :create do
          # Software installation
          package "#{new_resource.parsed_name} :create #{new_resource.parsed_package_name}" do
            package_name new_resource.parsed_package_name
            action new_resource.parsed_package_action
            version new_resource.parsed_package_version
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

          directory "#{new_resource.parsed_name} :create #{base_dir}/var/log/#{mysql_name}" do
            path "#{base_dir}/var/log/#{mysql_name}"
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
            notifies :run, "bash[#{new_resource.parsed_name} :create initial records]"
            action :run
          end

          bash "#{new_resource.parsed_name} :create initial records" do
            code init_records_script
            action :nothing
          end
        end

        action :start do
          template "#{new_resource.parsed_name} :start /usr/libexec/#{mysql_name}-wait-ready" do
            path "/usr/libexec/#{mysql_name}-wait-ready"
            source 'systemd/mysqld-wait-ready.erb'            
            owner 'root'
            group 'root'
            mode '0755'
            variables(
              :socket_file => socket_file,
              :data_dir => new_resource.parsed_data_dir
              )            
            cookbook 'mysql'
            action :create
          end
          
          template "#{new_resource.parsed_name} :start /usr/lib/systemd/system#{mysql_name}.service" do
            path "/usr/lib/systemd/system/#{mysql_name}.service"
            source 'systemd/mysqld.service.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(
              :base_dir => base_dir,
              :etc_dir => etc_dir,
              :mysql_name => mysql_name,
              :run_user => new_resource.parsed_run_user,
              :run_group => new_resource.parsed_run_group
              )
            cookbook 'mysql'
            action :create
          end

          service "#{new_resource.parsed_name} :start #{mysql_name}" do
            service_name mysql_name
            provider Chef::Provider::Service::Systemd
            supports :restart => true, :status => true
            action [:start]
          end
        end

        action :delete do
        end
        
        action :restart do
        end

        action :reload do
        end
      end
    end
  end
end
