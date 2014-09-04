require 'spec_helper'

describe 'mysql_service::multi on debian-7.2' do
  let(:mysql_service_multi_55_debian_7_2) do
    ChefSpec::Runner.new(
      :platform => 'debian',
      :version => '7.2') do |node|
      node.set['mysql']['version'] = '5.5'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data/instance-2'
      node.set['mysql']['run_user'] = 'bob'
      node.set['mysql']['allow_remote_root'] = false
      node.set['mysql']['remove_anonymous_users'] = false
      node.set['mysql']['remove_test_database'] = false
      node.set['mysql']['server_root_password'] = 'never gonna make you cry'
      node.set['mysql']['server_debian_password'] = 'never gonna say goodbye'
      node.set['mysql']['server_repl_password'] = 'never gonna tell a lie and hurt you'
    end.converge('mysql_service::multi')
  end

  context 'compiling the recipe' do
    it 'creates group[alice]' do
      expect(mysql_service_multi_55_debian_7_2).to create_group('alice')
    end

    it 'creates user[alice]' do
      expect(mysql_service_multi_55_debian_7_2).to create_user('alice')
    end

    it 'creates group[bob]' do
      expect(mysql_service_multi_55_debian_7_2).to create_group('bob')
    end

    it 'creates user[bob]' do
      expect(mysql_service_multi_55_debian_7_2).to create_user('bob')
    end

    it 'creates mysql_service[instance-1]' do
      expect(mysql_service_multi_55_debian_7_2).to create_mysql_service('instance-1')
        .with(
        :parsed_version => '5.5',
        :parsed_port => '3307',
        :parsed_data_dir => '/data/instance-1',
        :parsed_run_user => 'alice',
        :parsed_allow_remote_root => true,
        :parsed_remove_anonymous_users => true,
        :parsed_remove_test_database => true,
        :parsed_root_network_acl => ['0.0.0.0'],
        :parsed_server_root_password => 'never gonna give you up',
        :parsed_server_debian_password => 'never gonna let you down',
        :parsed_server_repl_password => 'never_gonna_run_around_and_desert_you'
        )
    end

    it 'creates mysql_service[instance-2]' do
      expect(mysql_service_multi_55_debian_7_2).to create_mysql_service('instance-2')
        .with(
        :parsed_version => '5.5',
        :parsed_port => '3308',
        :parsed_data_dir => '/data/instance-2',
        :parsed_run_user => 'bob',
        :parsed_allow_remote_root => false,
        :parsed_remove_anonymous_users => false,
        :parsed_remove_test_database => false,
        :parsed_root_network_acl => [],
        :parsed_server_root_password => 'never gonna make you cry',
        :parsed_server_debian_password => 'never gonna say goodbye',
        :parsed_server_repl_password => 'never gonna tell a lie and hurt you'
        )
    end
  end
end
