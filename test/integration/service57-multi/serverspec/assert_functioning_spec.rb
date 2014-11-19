require 'serverspec'

set :backend, :exec

def mysql_bin
  return '/opt/mysql51/bin/mysql' if os[:family] =~ /solaris/
  '/usr/bin/mysql'
end

def instance_1_cmd
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3307 \
  -u root \
  -pilikerandompasswords \
  -e "SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%';" \
  --skip-column-names
  EOF
end

def instance_2_cmd
  <<-EOF
  #{mysql_bin} \
  -h 127.0.0.1 \
  -P 3308 \
  -u root \
  -pstring\\ with\\ spaces \
  -e "SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='%';" \
  --skip-column-names
  EOF
end

describe command(instance_1_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| % | root | *4C45527A2EBB585B4F5BAC0C29F4A20FB268C591 |/) }
end

describe command(instance_2_cmd) do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/| % | root | *4C45527A2EBB585B4F5BAC0C29F4A20FB268C591 |/) }
end
