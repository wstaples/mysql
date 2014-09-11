require 'serverspec'
include Serverspec::Helper::Exec

slave_1_cmd = '/usr/bin/mysql'
slave_1_cmd << ' -h 127.0.0.1'
slave_1_cmd << ' -P 3307'
slave_1_cmd << ' -u root'
slave_1_cmd << ' -pilikerandompasswords'
slave_1_cmd << ' -D databass'
slave_1_cmd << " -e \"select * from table1\" | grep awesome"

describe command(slave_1_cmd) do
  it { should return_exit_status 0 }
end

slave_2_cmd = '/usr/bin/mysql'
slave_2_cmd << ' -h 127.0.0.1'
slave_2_cmd << ' -P 3307'
slave_2_cmd << ' -u root'
slave_2_cmd << ' -pilikerandompasswords'
slave_2_cmd << ' -D databass'
slave_2_cmd << " -e \"select * from table1\" | grep awesome"

describe command(slave_2_cmd) do
  it { should return_exit_status 0 }
end
