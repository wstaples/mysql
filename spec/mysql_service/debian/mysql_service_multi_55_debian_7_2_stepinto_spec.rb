require 'spec_helper'

describe 'mysql_service::multi on debian-7.2' do
  let(:mysql_service_multi_55_debian_7_2_stepinto) do
    ChefSpec::Runner.new(
      # :step_into => 'mysql_service',
      :platform => 'debian',
      :version => '7.2') do |node|
      node.set['mysql']['version'] = '5.5'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data/instance-2'
      node.set['mysql']['run_user'] = 'bob'
      node.set['mysql']['remove_anonymous_users'] = true
      node.set['mysql']['remove_test_database'] = true
      node.set['mysql']['root_acl'] = ['127.0.0.1', 'mercury', 'venus', 'earth']
      node.set['mysql']['repl_acl'] = ['127.0.0.1', '::1', 'localhost', 'mars', 'jupiter', 'saturn', 'uranus']
      node.set['mysql']['root_password'] = 'never gonna make you cry'
      node.set['mysql']['repl_password'] =  'never gonna say goodbye'
      node.set['mysql']['debian_password'] = 'never gonna tell a lie and hurt you'
    end.converge('mysql_service::multi')
  end

  before do
    stub_command('/usr/bin/test -f /data/instance-1/mysql/user.frm').and_return(true)
    stub_command('/usr/bin/test -f /data/instance-2/mysql/user.frm').and_return(true)
  end

  context 'compiling the recipe' do
    it 'creates group[alice]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_group('alice')
    end

    it 'creates user[alice]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_user('alice')
    end

    it 'creates group[bob]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_group('bob')
    end

    it 'creates user[bob]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_user('bob')
    end

    it 'creates mysql_service[instance-1]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_mysql_service('instance-1')
        .with(
        :parsed_version => '5.5',
        :parsed_port => '3307',
        :parsed_data_dir => '/data/instance-1',
        :parsed_run_user => 'alice',
        :parsed_remove_anonymous_users => true,
        :parsed_remove_test_database => true,
        :parsed_root_acl => ['%'],
        :parsed_repl_acl => [],
        :parsed_root_password => 'never gonna give you up',
        :parsed_repl_password => 'never gonna let you down',
        :parsed_debian_password => 'never gonna run around and desert you'
        )
    end

    it 'creates mysql_service[instance-2]' do
      expect(mysql_service_multi_55_debian_7_2_stepinto).to create_mysql_service('instance-2')
        .with(
        :parsed_version => '5.5',
        :parsed_port => '3308',
        :parsed_data_dir => '/data/instance-2',
        :parsed_run_user => 'bob',
        :parsed_remove_anonymous_users => true,
        :parsed_remove_test_database => true,
        :parsed_root_acl => ['127.0.0.1', 'mercury', 'venus', 'earth'],
        :parsed_repl_acl => ['127.0.0.1', '::1', 'localhost', 'mars', 'jupiter', 'saturn', 'uranus'],
        :parsed_root_password => 'never gonna make you cry',
        :parsed_repl_password => 'never gonna say goodbye',
        :parsed_debian_password => 'never gonna tell a lie and hurt you'
        )
    end
  end
end
