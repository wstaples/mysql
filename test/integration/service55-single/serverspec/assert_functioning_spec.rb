require 'serverspec'

include Serverspec::Helper::Exec

cmd = '/usr/bin/mysql'
cmd << ' -h 127.0.0.1'
cmd << ' -P 3306'
cmd << ' -u root'
cmd << ' -pilikerandompasswords'
cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' OR User='repl'; \""

describe command(cmd) do
  it { should return_exit_status 0 }
end
