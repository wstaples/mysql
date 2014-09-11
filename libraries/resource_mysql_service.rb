require 'chef/resource/lwrp_base'
require_relative 'helpers'

class Chef
  class Resource
    class MysqlService < Chef::Resource::LWRPBase
      self.resource_name = :mysql_service
      actions :create, :delete, :restart, :reload
      default_action :create

      attribute :data_dir, :kind_of => String, :default => nil
      attribute :debian_password, :kind_of => String, :default => 'gnuslashlinux4ev4r'
      attribute :instance, :kind_of => String, :name_attribute => true
      attribute :package_action, :kind_of => String, :default => nil
      attribute :package_name, :kind_of => String, :default => nil
      attribute :package_version, :kind_of => String, :default => nil
      attribute :port, :kind_of => String, :default => '3306'
      attribute :remove_anonymous_users, :kind_of => [TrueClass, FalseClass], :default => true
      attribute :remove_test_database, :kind_of => [TrueClass, FalseClass], :default => true
      attribute :repl_acl, :kind_of => Array, :default => []
      attribute :repl_password, :kind_of => String, :default => nil
      attribute :root_acl, :kind_of => Array, :default => ['127.0.0.1', '::1', 'localhost']
      attribute :root_password, :kind_of => String, :default => 'ilikerandompasswords'
      attribute :run_group, :kind_of => String, :default => 'mysql'
      attribute :run_user, :kind_of => String, :default => 'mysql'
      attribute :version, :kind_of => String, :default => nil
    end

    include Opscode::Mysql::Helpers

    def parsed_allow_remote_root
      return allow_remote_root unless allow_remote_root.nil?
    end

    def parsed_data_dir
      return data_dir if data_dir
      case node['platform_family']
      when 'rhel', 'fedora', 'suse', 'debian', 'omnios'
        data_dir = "/var/lib/mysql-#{instance}"
      when 'smartos'
        data_dir = "/opt/local/lib/mysql-#{instance}"
      when 'freebsd'
        data_dir = "/var/db/mysql-#{instance}"
      end
      data_dir
    end

    def parsed_instance
      return instance if instance
    end

    def parsed_name
      return name if name
    end

    def parsed_package_name
      return package_name if package_name
      package_name_for(
        node['platform'],
        node['platform_family'],
        node['platform_version'],
        parsed_version
        )
    end

    def parsed_package_version
      return package_version if package_version
    end

    def parsed_package_action
      return package_action if package_action
    end

    def parsed_port
      return port if port
    end

    def parsed_remove_anonymous_users
      return remove_anonymous_users unless remove_anonymous_users.nil?
    end

    def parsed_remove_test_database
      return remove_test_database unless remove_test_database.nil?
    end

    def parsed_root_network_acl
      return root_network_acl if root_network_acl
    end

    def parsed_run_user
      return run_user if run_user
    end

    def parsed_run_group
      return run_group if run_group
    end

    def parsed_debian_password
      return debian_password if debian_password
    end

    def parsed_repl_acl
      return repl_acl if repl_acl
    end

    def parsed_repl_password
      return repl_password if repl_password
    end

    def parsed_root_acl
      return root_acl if root_acl
    end

    def parsed_root_password
      return root_password if root_password
    end

    def parsed_version
      return version if version
      case node['platform_family']
      when 'rhel'
        case node['platform_version'].to_i
        when 5
          default_version = '5.0'
        when 2013, 6
          default_version = '5.1'
        when 2014, 7
          default_version = '5.5'
        end
      when 'fedora'
        default_version = '5.5'
      when 'suse'
        default_version = '5.5'
      when 'debian'
        return '5.1' if node['platform_version'].to_i == 6
        return '5.5' if node['platform_version'].to_i == 7
        case node['platform_version']
        when 'jessie/sid', '12.04', '13.04', '13.10', '14.04'
          default_version = '5.5'
        when '10.04'
          default_version = '5.1'
        end
      when 'smartos'
        default_version = '5.5'
      when 'omnios'
        default_version = '5.5'
      when 'freebsd'
        default_version = '5.5'
      end
      default_version
    end
  end
end
