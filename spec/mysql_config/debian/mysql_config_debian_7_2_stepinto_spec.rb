require 'spec_helper'

describe 'mysql_config::default on debian-7.2' do
  let(:mysql_config_debian_7_2_stepinto) do
    ChefSpec::Runner.new(
      :step_into => 'mysql_config',
      :platform => 'debian',
      :version => '7.2'
      ).converge('mysql_config::default')
  end

  context 'compiling the recipe' do
    it 'creates mysql_config[hello]' do
      expect(mysql_config_debian_7_2_stepinto).to create_mysql_config('hello')
    end

    it 'creates mysql_config[hello_again]' do
      expect(mysql_config_debian_7_2_stepinto).to create_mysql_config('hello_again')
    end
  end

  context 'stepping into mysql_config' do
  end
end
