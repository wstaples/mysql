require 'spec_helper'

describe 'mysql_service::single on centos-5.8' do
  let(:mysql_service_multi_55_centos_5_8_stepinto) do
    ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '5.8',
      :step_into => 'mysql_service'
      ) do |node|
      node.set['mysql']['version'] = '5.5'
      node.set['mysql']['port'] = '3308'
      node.set['mysql']['data_dir'] = '/data/instance-2'
      node.set['mysql']['run_user'] = 'bob'
      node.set['mysql']['run_group'] = 'bob'
      node.set['mysql']['initial_root_password'] = 'string with spaces'
    end.converge('mysql_service::multi')
  end

  before do
    stub_command('/usr/bin/test -f /data/instance-1/mysql/user.frm').and_return(true)
  end

  before do
    stub_command('/usr/bin/test -f /data/instance-2/mysql/user.frm').and_return(true)
  end

  #
  # Resource in mysql_service::single
  #
  context 'compiling the test recipe' do
    it 'creates user[alice]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_user('alice')
    end

    it 'creates group[alice]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_group('alice')
    end

    it 'creates user[bob]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_user('bob')
    end

    it 'creates group[bob]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_group('bob')
    end

    it 'deletes mysql_service[default]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to delete_mysql_service('default')
    end

    it 'creates mysql_service[instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_mysql_service('instance-1')
    end

    it 'creates mysql_service[instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_mysql_service('instance-2')
    end
  end

  #
  # mysql_service resource action implementations
  #

  # mysql_service action :delete instance-1
  context 'stepping into mysql_service[default] resource' do
    # FIXME: not implemented yet
  end

  # mysql_service[instance-1] with action [:create, :start]
  context 'stepping into mysql_service[instance-1] resource' do
    it 'installs package[instance-1 :create mysql55-mysql-server]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to install_package('instance-1 :create mysql55-mysql-server')
        .with(:package_name => 'mysql55-mysql-server', :version => nil)
    end

    it 'creates group[instance-1 :create mysql]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_group('instance-1 :create mysql')
        .with(:group_name => 'mysql')
    end

    it 'creates user[instance-1 :create mysql]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_user('instance-1 :create mysql')
        .with(:username => 'mysql')
    end

    it 'deletes file[instance-1 :create /opt/rh/mysql55/root/etc/mysql/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to delete_file('instance-1 :create /opt/rh/mysql55/root/etc/mysql/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-1 :create /opt/rh/mysql55/root/etc/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to delete_file('instance-1 :create /opt/rh/mysql55/root/etc/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/my.cnf')
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-1',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1/conf.d]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1/conf.d')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-1/conf.d',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql55/root/var/run/mysql-instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-1 :create /opt/rh/mysql55/root/var/run/mysql-instance-1')
        .with(
        :path => '/opt/rh/mysql55/root/var/run/mysql-instance-1',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'creates directory[instance-1 :create /opt/rh/mysql55/root/var/log/mysql-instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-1 :create /opt/rh/mysql55/root/var/log/mysql-instance-1')
        .with(
        :path => '/opt/rh/mysql55/root/var/log/mysql-instance-1',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-1 :create /data/instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-1 :create /data/instance-1')
        .with(
        :path => '/data/instance-1',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates template[instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_template('instance-1 :create /opt/rh/mysql55/root/etc/mysql-instance-1/my.cnf')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-1/my.cnf',
        :owner => 'alice',
        :group => 'alice',
        :mode => '0600'
        )
    end

    it 'runs bash[instance-1 :create initialize mysql database]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to_not run_bash('instance-1 :create initialize mysql database')
        .with(
        :cwd => '/data/instance-1'
        )
    end

    it 'runs bash[instance-1 :create initial records]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to_not run_bash('instance-1 :create initial records')
    end

    it 'create template[instance-1 :start /etc/init.d/mysql-instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_template('instance-1 :start /etc/init.d/mysql-instance-1')
        .with(
        :path => '/etc/init.d/mysql-instance-1',
        :source => 'sysvinit/rhel/scl-sysvinit.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :cookbook => 'mysql'
        )
    end

    it 'starts service[instance-1 :start mysql-instance-1]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to start_service('instance-1 :start mysql-instance-1')
        .with(
        :service_name => 'mysql-instance-1',
        :provider => Chef::Provider::Service::Init
        )
    end
  end

  # mysql_service[instance-2] with action [:create, :start]
  context 'stepping into mysql_service[instance-2] resource' do
    it 'installs package[instance-2 :create mysql55-mysql-server]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to install_package('instance-2 :create mysql55-mysql-server')
        .with(:package_name => 'mysql55-mysql-server', :version => nil)
    end

    it 'creates group[instance-2 :create mysql]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_group('instance-2 :create mysql')
        .with(:group_name => 'mysql')
    end

    it 'creates user[instance-2 :create mysql]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_user('instance-2 :create mysql')
        .with(:username => 'mysql')
    end

    it 'deletes file[instance-2 :create /opt/rh/mysql55/root/etc/mysql/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to delete_file('instance-2 :create /opt/rh/mysql55/root/etc/mysql/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/mysql/my.cnf')
    end

    it 'deletes file[instance-2 :create /opt/rh/mysql55/root/etc/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to delete_file('instance-2 :create /opt/rh/mysql55/root/etc/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/my.cnf')
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-2',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2/conf.d]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2/conf.d')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-2/conf.d',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql55/root/var/run/mysql-instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-2 :create /opt/rh/mysql55/root/var/run/mysql-instance-2')
        .with(
        :path => '/opt/rh/mysql55/root/var/run/mysql-instance-2',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'creates directory[instance-2 :create /opt/rh/mysql55/root/var/log/mysql-instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-2 :create /opt/rh/mysql55/root/var/log/mysql-instance-2')
        .with(
        :path => '/opt/rh/mysql55/root/var/log/mysql-instance-2',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[instance-2 :create /data/instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_directory('instance-2 :create /data/instance-2')
        .with(
        :path => '/data/instance-2',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates template[instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2/my.cnf]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_template('instance-2 :create /opt/rh/mysql55/root/etc/mysql-instance-2/my.cnf')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-instance-2/my.cnf',
        :owner => 'bob',
        :group => 'bob',
        :mode => '0600'
        )
    end

    it 'runs bash[instance-2 :create initialize mysql database]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to_not run_bash('instance-2 :create initialize mysql database')
        .with(
        :cwd => '/data/instance-2'
        )
    end

    it 'runs bash[instance-2 :create initial records]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to_not run_bash('instance-2 :create initial records')
    end

    it 'create template[instance-2 :start /etc/init.d/mysql-instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to create_template('instance-2 :start /etc/init.d/mysql-instance-2')
        .with(
        :path => '/etc/init.d/mysql-instance-2',
        :source => 'sysvinit/rhel/scl-sysvinit.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :cookbook => 'mysql'
        )
    end

    it 'starts service[instance-2 :start mysql-instance-2]' do
      expect(mysql_service_multi_55_centos_5_8_stepinto).to start_service('instance-2 :start mysql-instance-2')
        .with(
        :service_name => 'mysql-instance-2',
        :provider => Chef::Provider::Service::Init
        )
    end
  end
end
