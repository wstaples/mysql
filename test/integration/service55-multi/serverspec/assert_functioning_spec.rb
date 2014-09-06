require 'serverspec'

include Serverspec::Helper::Exec

instance_1_cmd = "/usr/bin/mysql"
instance_1_cmd << " -h 127.0.0.1"
instance_1_cmd << " -P 3307"
instance_1_cmd << " -u root"
instance_1_cmd << " -pnever\\ gonna\\ give\\ you\\ up"
instance_1_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' OR User='repl'; \""

describe command(instance_1_cmd) do
  it { should return_exit_status 0 }
end

instance_2_cmd = "/usr/bin/mysql"
instance_2_cmd << " -h 127.0.0.1"
instance_2_cmd << " -P 3308"
instance_2_cmd << " -u root"
instance_2_cmd << " -pnever\\ gonna\\ make\\ you\\ cry"
instance_2_cmd << " -e \"SELECT Host,User,Password FROM mysql.user WHERE User='root' OR User='repl'; \""

describe command(instance_2_cmd) do
  it { should return_exit_status 0 }
end
