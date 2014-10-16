require 'serverspec'

set :backend, :exec

if os[:family] =~ /solaris/
  cmd = '/opt/mysql55/bin/mysql'
else
  cmd = '/usr/bin/mysql'
end

cmd << ' -h 127.0.0.1'
cmd << ' -P 3306'
cmd << ' -u root'
cmd << ' -pilikerandompasswords'
cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' OR User='repl'; \""

describe command(cmd) do
  its(:exit_status) { should eq 0 }
end
