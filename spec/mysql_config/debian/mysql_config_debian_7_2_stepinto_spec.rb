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
    # hello
    it 'creates group[hello :create mysql]' do
      expect(mysql_config_debian_7_2_stepinto).to create_group('hello :create mysql')
        .with(
        :group_name => 'mysql'
        )
    end

    it 'creates user[hello :create mysql]' do
      expect(mysql_config_debian_7_2_stepinto).to create_user('hello :create mysql')
        .with(
        :username => 'mysql',
        :gid => 'mysql'
        )
    end

    it 'creates directory[hello :create /etc/mysql-default/conf.d]' do
      expect(mysql_config_debian_7_2_stepinto).to create_directory(
       'hello :create /etc/mysql-default/conf.d'
        ).with(
        :path => '/etc/mysql-default/conf.d',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates template[hello :create /etc/mysql-default/conf.d/hello.cnf]' do
      expect(mysql_config_debian_7_2_stepinto).to create_template(
        'hello :create /etc/mysql-default/conf.d/hello.cnf'
        ).with(
        :path => '/etc/mysql-default/conf.d/hello.cnf',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0640'
        )
    end

    # hello_again
    it 'creates group[hello_again :create mysql]' do
      expect(mysql_config_debian_7_2_stepinto).to create_group('hello_again :create mysql')
        .with(
        :group_name => 'mysql'
        )
    end

    it 'creates user[hello_again :create mysql]' do
      expect(mysql_config_debian_7_2_stepinto).to create_user('hello_again :create mysql')
        .with(
        :username => 'mysql',
        :gid => 'mysql'
        )
    end

    it 'creates directory[hello_again :create /etc/mysql-foo/conf.d]' do
      expect(mysql_config_debian_7_2_stepinto).to create_directory(
        'hello_again :create /etc/mysql-foo/conf.d'
        ).with(
        :path => '/etc/mysql-foo/conf.d',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates template[hello_again :create /etc/mysql-foo/conf.d/hello_again.cnf]' do
      expect(mysql_config_debian_7_2_stepinto).to create_template(
        'hello_again :create /etc/mysql-foo/conf.d/hello_again.cnf'
        ).with(
        :path => '/etc/mysql-foo/conf.d/hello_again.cnf',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0640'
        )
    end
  end
end
