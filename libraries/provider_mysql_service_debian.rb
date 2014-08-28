require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers_debian'

class Chef
  class Provider
    class MysqlService
      class Debian < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        include Mysql::Helpers::Debian

        action :create do
          # go home dpkg you're drunk
          bash "#{new_resource.parsed_name} create install mysql package" do
            code <<-EOF
            mkdir -p /tmp/dpk-hack
            ln -s /bin/true /tmp/dpk-hack/bash
            ln -s /bin/true /tmp/dpk-hack/whiptail
            ln -s /bin/true /tmp/dpk-hack/initctl
            ln -s /bin/true /tmp/dpk-hack/invoke-rc.d
            ln -s /bin/true /tmp/dpk-hack/restart
            ln -s /bin/true /tmp/dpk-hack/start
            ln -s /bin/true /tmp/dpk-hack/stop
            ln -s /bin/true /tmp/dpk-hack/start-stop-daemon
            ln -s /bin/true /tmp/dpk-hack/service
            PATH=/tmp/dpk-hack:$PATH apt-get -y install #{new_resource.parsed_package_name}
            EOF
            not_if "/usr/bin/dpkg -l | awk '{ print $2 }' | grep #{new_resource.parsed_package_name}"
          end

          group "#{new_resource.parsed_name} create #{new_resource.parsed_run_group}" do
            group_name new_resource.parsed_run_group
            system true if new_resource.parsed_run_group == 'mysql'
            action :create
          end

          user "#{new_resource.parsed_name} create #{new_resource.parsed_run_user}" do
            username new_resource.parsed_run_user
            gid new_resource.parsed_run_group
            system true if new_resource.parsed_run_group == 'mysql'
            action :create
          end
          
          # support directories
          directory "#{new_resource.parsed_name} create run_dir" do
            path run_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0755'
            action :create
            recursive true
          end

          directory "#{new_resource.parsed_name} create include_dir" do
            path include_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          directory "#{new_resource.parsed_name} create #{new_resource.parsed_data_dir}" do
            path new_resource.parsed_data_dir
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0750'
            recursive true
            action :create
          end

          template "#{new_resource.parsed_name} create /etc/#{mysql_name}/my.cnf" do
            path "/etc/#{mysql_name}/my.cnf"
            source "#{new_resource.parsed_version}/my.cnf.erb"
            cookbook 'mysql'
            owner new_resource.parsed_run_user
            group new_resource.parsed_run_group
            mode '0600'
            variables(
              :data_dir => new_resource.parsed_data_dir,
              :pid_file => pid_file,
              :socket_file => socket_file,
              :port => new_resource.parsed_port,
              :include_dir => include_dir
              )
            action :create
#            notifies :restart, "service[#{new_resource.parsed_name} create #{mysql_name}]"
          end
          
          # execute "#{new_resource.parsed_name} create initialize mysql database" do
          #   user new_resource.parsed_run_user
          #   cwd new_resource.parsed_data_dir
          #   cmd = '/usr/bin/mysql_install_db'
          #   cmd << " --datadir=#{new_resource.parsed_data_dir}"
          #   cmd << " --user=#{new_resource.parsed_run_user}"
          #   command cmd
          #   creates "#{new_resource.parsed_data_dir}/mysql/user.frm"
          # end

          # # service
          # template "/etc/#{mysql_name}/debian.cnf" do
          #   cookbook 'mysql'
          #   source 'debian/debian.cnf.erb'
          #   owner 'root'
          #   group 'root'
          #   mode '0600'
          #   variables(:config => new_resource)
          #   action :create
          # end

          # # init script
          # template "#{new_resource.parsed_name} create /etc/init.d/#{mysql_name}" do
          #   path "/etc/init.d/#{mysql_name}"
          #   source "#{mysql_version}/sysvinit/#{platform_and_version}/mysql.erb"
          #   owner 'root'
          #   group 'root'
          #   mode '0755'
          #   variables(:mysql_name => mysql_name)
          #   cookbook 'mysql'
          #   action :create
          # end

          # service "#{new_resource.parsed_name} create #{mysql_name}" do
          #   service_name mysql_name
          #   provider Chef::Provider::Service::Init::Debian
          #   supports :restart => true
          #   action [:start, :enable]
          # end

          # execute "#{new_resource.parsed_name} create assign-root-password" do
          #   cmd = '/usr/bin/mysqladmin'
          #   cmd << ' -u root password '
          #   cmd << Shellwords.escape(new_resource.parsed_server_root_password)
          #   command cmd
          #   action :run
          #   only_if "/usr/bin/mysql -u root -e 'show databases;'"
          # end

          # template "#{new_resource.parsed_name} create /etc/#{mysql_name}/grants.sql" do
          #   path "/etc/#{mysql_name}/grants.sql"
          #   cookbook 'mysql'
          #   source 'grants/grants.sql.erb'
          #   owner 'root'
          #   group 'root'
          #   mode '0600'
          #   variables(:config => new_resource)
          #   action :create
          #   notifies :run, "execute[#{new_resource.parsed_name} create install-grants]"
          # end

          # execute "#{new_resource.parsed_name} create install-grants" do
          #   cmd = '/usr/bin/mysql'
          #   cmd << ' -u root '
          #   cmd << "#{pass_string} < /etc/#{mysql_name}/grants.sql"
          #   command cmd
          #   action :nothing
          #   notifies :run, "execute[#{new_resource.parsed_name} create root marker]"
          # end

          # execute "#{new_resource.parsed_name} create root marker" do
          #   cmd = '/bin/echo'
          #   cmd << " '#{Shellwords.escape(new_resource.parsed_server_root_password)}'"
          #   cmd << " > /etc/#{mysql_name}/.mysql_root"
          #   cmd << " ;/bin/chmod 0600 /etc/#{mysql_name}/.mysql_root"
          #   command cmd
          #   action :nothing
          # end
        end
      end

      action :restart do
        service 'mysql' do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Debian
          supports :restart => true
          action :restart
        end
      end

      action :reload do
        service 'mysql' do
          service_name mysql_name
          provider Chef::Provider::Service::Init::Debian
          action :reload
        end
      end
    end
  end
end
