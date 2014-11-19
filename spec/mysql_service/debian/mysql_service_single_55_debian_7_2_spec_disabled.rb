require 'spec_helper'

describe 'mysql_service::single on debian-7.2' do
  let(:mysql_service_single_55_debian_7_2) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => '7.2').converge('mysql_service::single')
  end

  context 'compiling the recipe' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_single_55_debian_7_2).to create_mysql_service('default')
    end
  end
end
