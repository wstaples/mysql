require 'chef/resource/lwrp_base'
require_relative 'helpers'

class Chef
  class Resource
    class MysqlConfig < Chef::Resource::LWRPBase
      self.resource_name = :mysql_config
      actions :create, :delete
      default_action :create

      attribute :config_name, :kind_of => String, :name_attribute => true, :required => true
      attribute :cookbook, :kind_of => String, :default => nil
      attribute :mysql_version, :kind_of => String, :default => nil
      attribute :instance, :kind_of => String, :default => 'default'
      attribute :source, :kind_of => String, :default => nil
      attribute :variables, :kind_of => [Hash], :default => nil

      include MysqlCookbook::Helpers::Debian

      def parsed_name
        return name if name
      end

      def parsed_config_name
        return config_name if config_name
      end

      def parsed_cookbook
        return cookbook if cookbook
      end

      def parsed_mysql_version
        # FIXME
      end

      def parsed_instance
        return instance if instance
      end

      def parsed_source
        return source if source
      end

      def parsed_variables
        return variables if variables
      end
    end
  end
end
