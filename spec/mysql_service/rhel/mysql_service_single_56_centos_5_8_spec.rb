require 'spec_helper'

describe 'mysql_service::single on centos-5.8' do
  let(:mysql_service_single_56_centos_5_8) do
    ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '5.8'
      ) do |node|
      node.set['mysql']['version'] = '5.6'
    end.converge('mysql_service::single')
  end

  context 'compiling the recipe' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_single_56_centos_5_8).to create_mysql_service('default')
    end
  end
end
