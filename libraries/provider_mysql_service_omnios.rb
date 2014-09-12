require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers_omnios'

include Opscode::Mysql::Helpers

class Chef
  class Provider
    class MysqlService
      class Omnios < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

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
            action :create
            recursive true
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
            action :create
            notifies :restart, "service[#{new_resource.parsed_name} :create #{mysql_name}]"
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
              :base_dir => base_dir,
              :data_dir => new_resource.parsed_data_dir,
              :pid_file => pid_file,
              :my_cnf => my_cnf
              )
            action :create
          end

          template "#{new_resource.parsed_name} :create /tmp/mysql.xml" do
            path "/tmp/#{mysql_name}.xml"
            cookbook 'mysql'
            source 'omnios/mysql.xml.erb'
            owner 'root'
            mode '0644'
            variables(
              :version => new_resource.parsed_version,
              :mysql_name => mysql_name
              )
            action :create
            notifies :run, "execute[import #{mysql_name} manifest]", :immediately
          end

          execute "import #{mysql_name} manifest" do
            command "svccfg import /tmp/#{mysql_name}.xml"
            action :nothing
          end

          service "#{new_resource.parsed_name} :create #{mysql_name}" do
            service_name mysql_name
            supports :restart => true
            action [:start, :enable]
          end

          # execute 'wait for mysql' do
          #   command "until [ -S #{socket_file} ] ; do sleep 1 ; done"
          #   timeout 10
          #   action :run
          # end

          # execute 'assign-root-password' do
          #   cmd = "#{prefix_dir}/bin/mysqladmin"
          #   cmd << ' -u root password '
          #   cmd << Shellwords.escape(new_resource.parsed_root_password)
          #   command cmd
          #   action :run
          #   only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
          # end

          # template '/etc/mysql_grants.sql' do
          #   cookbook 'mysql'
          #   source 'grants/grants.sql.erb'
          #   owner 'root'
          #   group 'root'
          #   mode '0600'
          #   variables(:config => new_resource)
          #   action :create
          #   notifies :run, 'execute[install-grants]'
          # end

          # execute 'install-grants' do
          #   cmd = "#{prefix_dir}/bin/mysql"
          #   cmd << ' -u root '
          #   cmd << "#{pass_string} < /etc/mysql_grants.sql"
          #   command cmd
          #   retries 5
          #   retry_delay 2
          #   action :nothing
          #   notifies :run, 'execute[create root marker]'
          # end

          # execute 'create root marker' do
          #   cmd = '/bin/echo'
          #   cmd << " '#{Shellwords.escape(new_resource.parsed_root_password)}'"
          #   cmd << ' > /etc/.mysql_root'
          #   cmd << ' ;/bin/chmod 0600 /etc/.mysql_root'
          #   command cmd
          #   action :nothing
          # end
        end

        action :restart do
          service 'mysql' do
            supports :restart => true
            action :restart
          end
        end

        action :reload do
          service 'mysql' do
            supports :reload => true
            action :reload
          end
        end
      end
    end
  end
end
