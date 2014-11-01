require 'serverspec'

set :backend, :exec

if os[:family] =~ /solaris/
  cmd = '/opt/mysql56/bin/mysql'
else
  cmd = '/usr/bin/mysql'
end

instance_1_cmd = cmd
instance_1_cmd << ' -S /var/run/mysql-instance-1/mysql-instance-1.sock'
instance_1_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%'; \""

describe command(instance_1_cmd) do
  its(:exit_status) { should eq 0 }
end

instance_2_cmd = cmd
instance_2_cmd << ' -S /var/run/mysql-instance-2/mysql-instance-2.sock'
instance_2_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' AND HOST='%'; \""

describe command(instance_2_cmd) do
  its(:exit_status) { should eq 0 }
end
