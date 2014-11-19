require 'chef/provider/lwrp_base'
require_relative 'helpers_rhel'

class Chef
  class Provider
    class MysqlConfig
      class Fedora < Chef::Provider::MysqlConfig
        use_inline_resources if defined?(use_inline_resources)

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
