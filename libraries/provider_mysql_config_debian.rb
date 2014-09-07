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
          puts "SEANDEBUG: wat"
          directory "#{new_resource.parsed_name} create /etc/#{mysql_name}/conf.d" do
            path "/etc/#{mysql_name}/conf.d"
            owner 'root'
            group 'root'
            mode '0755'
            recursive true
            action :create
          end

          template "#{new_resource.parsed_name} create /etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf" do
            path "/etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf"
            owner 'root'
            group 'root'
            mode '0644'
            variables(new_resource.parsed_variables)
            source new_resource.parsed_source
            cookbook new_resource.parsed_cookbook
            action :create
          end
        end

        action :delete do
          file "#{new_resource.parsed_name} create /etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf" do
            path "/etc/#{mysql_name}/conf.d/#{new_resource.parsed_config_name}.conf"
            action :delete
          end
        end
      end
    end
  end
end
