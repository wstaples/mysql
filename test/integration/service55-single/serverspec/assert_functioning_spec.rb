require 'serverspec'

set :backend, :exec

def mysql_bin  
  return '/opt/mysql55/bin/mysql' if os[:family] =~ /solaris/
  return '/usr/bin/mysql'
end

def mysql_cmd
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3306 \
  -u root \
  -e "SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%';" \
  --skip-column-names
  EOF
end

describe command(mysql_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /| % | root |  |/ }
end
