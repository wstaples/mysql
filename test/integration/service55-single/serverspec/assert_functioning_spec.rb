require 'serverspec'

set :backend, :exec

if os[:family] =~ /solaris/
  cmd = '/opt/mysql55/bin/mysql'
else
  cmd = '/usr/bin/mysql'
end

cmd << ' -S /var/run/mysql-default/mysql-default.sock'
cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' AND host='%'; \""

describe command(cmd) do
  its(:exit_status) { should eq 0 }
end
