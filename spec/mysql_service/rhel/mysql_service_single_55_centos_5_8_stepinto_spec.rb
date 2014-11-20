require 'spec_helper'

describe 'mysql_service::single on centos-5.8' do
  let(:mysql_service_single_55_centos_5_8_stepinto) do
    ChefSpec::Runner.new(
      :platform => 'centos',
      :version => '5.8',
      :step_into => 'mysql_service'
      ) do |node|
        node.set['mysql']['version'] = '5.5'
      end.converge('mysql_service::single')
  end

  before do
    stub_command('/usr/bin/test -f /var/lib/mysql-default/mysql/user.frm').and_return(true)
  end

  # Resource in mysql_service::single
  context 'compiling the test recipe' do
    it 'creates mysql_service[default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_mysql_service('default')
    end
  end

  # mysql_service resource internal implementation
  context 'stepping into mysql_service[default] resource' do
    it 'installs package[default :create mysql55-mysql-server]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to install_package('default :create mysql55-mysql-server')
        .with(:package_name => 'mysql55-mysql-server', :version => nil)
    end

    it 'creates group[default :create mysql]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_group('default :create mysql')
        .with(:group_name => 'mysql')
    end

    it 'creates user[default :create mysql]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_user('default :create mysql')
        .with(:username => 'mysql')
    end

    it 'deletes file[default :create /opt/rh/mysql55/root/etc/mysql/my.cnf]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to delete_file('default :create /opt/rh/mysql55/root/etc/mysql/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/mysql/my.cnf')
    end

    it 'deletes file[default :create /opt/rh/mysql55/root/etc/my.cnf]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to delete_file('default :create /opt/rh/mysql55/root/etc/my.cnf')
        .with(:path => '/opt/rh/mysql55/root/etc/my.cnf')
    end

    it 'creates directory[default :create /opt/rh/mysql55/root/etc/mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_directory('default :create /opt/rh/mysql55/root/etc/mysql-default')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-default',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[default :create /opt/rh/mysql55/root/etc/mysql-default/conf.d]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_directory('default :create /opt/rh/mysql55/root/etc/mysql-default/conf.d')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-default/conf.d',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[default :create /opt/rh/mysql55/root/var/run/mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_directory('default :create /opt/rh/mysql55/root/var/run/mysql-default')
        .with(
        :path => '/opt/rh/mysql55/root/var/run/mysql-default',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0755',
        :recursive => true
        )
    end

    it 'creates directory[default :create /opt/rh/mysql55/root/var/log/mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_directory('default :create /opt/rh/mysql55/root/var/log/mysql-default')
        .with(
        :path => '/opt/rh/mysql55/root/var/log/mysql-default',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates directory[default :create /var/lib/mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_directory('default :create /var/lib/mysql-default')
        .with(
        :path => '/var/lib/mysql-default',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0750',
        :recursive => true
        )
    end

    it 'creates template[default :create /opt/rh/mysql55/root/etc/mysql-default/my.cnf]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_template('default :create /opt/rh/mysql55/root/etc/mysql-default/my.cnf')
        .with(
        :path => '/opt/rh/mysql55/root/etc/mysql-default/my.cnf',
        :owner => 'mysql',
        :group => 'mysql',
        :mode => '0600'
        )
    end

    it 'runs bash[default :create initialize mysql database]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to_not run_bash('default :create initialize mysql database')
        .with(
        :cwd => '/opt/rh/mysql55/root/var/lib/mysql-default'
        )
    end

    it 'runs bash[default :create initial records]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to_not run_bash('default :create initial records')
    end

    it 'creates template[default :start /etc/init.d/mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to create_template('default :start /etc/init.d/mysql-default')
        .with(
        :path => '/etc/init.d/mysql-default',
        :source => 'sysvinit/rhel/scl-sysvinit.erb',
        :owner => 'root',
        :group => 'root',
        :mode => '0755',
        :cookbook => 'mysql'
        )
    end

    it 'starts service[default :start mysql-default]' do
      expect(mysql_service_single_55_centos_5_8_stepinto).to start_service('default :start mysql-default')
        .with(
        :service_name => 'mysql-default',
        :provider => Chef::Provider::Service::Init
        )
    end
  end
end
