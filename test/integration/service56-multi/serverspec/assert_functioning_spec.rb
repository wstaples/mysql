require 'serverspec'

set :backend, :exec

if os[:family] =~ /solaris/
  cmd = '/opt/mysql56/bin/mysql'
else
  cmd = '/usr/bin/mysql'
end

instance_1_cmd = cmd
instance_1_cmd << ' -h 127.0.0.1'
instance_1_cmd << ' -P 3307'
instance_1_cmd << ' -u root'
instance_1_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%'; \""

describe command(instance_1_cmd) do
  its(:exit_status) { should eq 0 }
end

instance_2_cmd = cmd
instance_2_cmd << ' -h 127.0.0.1'
instance_2_cmd << ' -P 3308'
instance_2_cmd << ' -u root'
instance_2_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%%'; \""

describe command(instance_2_cmd) do
  its(:exit_status) { should eq 0 }
end
