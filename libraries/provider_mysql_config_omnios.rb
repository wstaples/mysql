require 'chef/provider/lwrp_base'
require_relative 'helpers_omnios'

class Chef
  class Provider
    class MysqlConfig
      class Omnios < Chef::Provider::MysqlConfig
        use_inline_resources if defined?(use_inline_resources)

        # include MysqlCookbook::Helpers::Omnios

        def whyrun_supported?
          true
        end

        action :create do
        end

        action :delete do
        end
      end
    end
  end
end
