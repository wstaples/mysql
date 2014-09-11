require 'chef/provider/lwrp_base'
require_relative 'helpers_debian'

class Chef
  class Provider
    class MysqlConfig
      class Debian < Chef::Provider::MysqlConfig
        use_inline_resources if defined?(use_inline_resources)

        include MysqlCookbook::Helpers::Debian

        def whyrun_supported?
          true
        end

        action :create do
          group "#{new_resource.parsed_name} :create #{new_resource.parsed_group}" do
            group_name new_resource.parsed_group
            action :create
          end

          user "#{new_resource.parsed_name} :create #{new_resource.parsed_owner}" do
            username new_resource.parsed_owner
            gid new_resource.parsed_owner
            action :create
          end

          directory "#{new_resource.parsed_name} :create /etc/#{mysql_name}/conf.d" do
            path "/etc/#{mysql_name}/conf.d"
            owner new_resource.parsed_owner
            group new_resource.parsed_group
            mode '0750'
            recursive true
            action :create
          end

          template "#{new_resource.parsed_name} :create /etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.cnf" do
            path "/etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.cnf"
            owner new_resource.parsed_owner
            group new_resource.parsed_group
            mode '0640'
            variables(new_resource.parsed_variables)
            source new_resource.parsed_source
            cookbook new_resource.parsed_cookbook
            action :create
          end
        end

        action :delete do
          file "#{new_resource.parsed_name} :create /etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf" do
            path "/etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf"
            action :delete
          end
        end
      end
    end
  end
end
