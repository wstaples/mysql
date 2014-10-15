module Opscode
  module Mysql
    module Helpers
      #######
      # FIXME: try and factor all this cruft out
      #######
      def package_name_for(platform, platform_family, platform_version, version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname][version]['package_name']
      rescue NoMethodError
        nil
      end

      def keyname_for(platform, platform_family, platform_version)
        case
        when platform_family == 'rhel'
          platform == 'amazon' ? platform_version : platform_version.to_i.to_s
        when platform_family == 'suse'
          platform_version
        when platform_family == 'fedora'
          platform_version
        when platform_family == 'debian'
          if platform == 'ubuntu'
            platform_version
          elsif platform_version =~ /sid$/
            platform_version
          else
            platform_version.to_i.to_s
          end
        when platform_family == 'smartos'
          platform_version
        when platform_family == 'omnios'
          platform_version
        when platform_family == 'freebsd'
          platform_version.to_i.to_s
        end
      rescue NoMethodError
        nil
      end
    end

    class PlatformInfo
      def self.mysql_info
        @mysql_info ||= {
          'rhel' => {
            '5' => {
              '5.0' => {
                'package_name' => 'mysql-server'
              },
              '5.1' => {
                'package_name' => 'mysql51-mysql-server'
              },
              '5.5' => {
                'package_name' => 'mysql55-mysql-server'
              }
            },
            '6' => {
              '5.1' => {
                'package_name' => 'mysql-server'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server'
              }
            },
            '7' => {
              '5.5' => {
                'package_name' => 'mysql-community-server'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server'
              }
            },
            '2013.03' => {
              '5.5' => {
                'package_name' => 'mysql-server'
              }
            },
            '2013.09' => {
              '5.1' => {
                'package_name' => 'mysql-server'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server'
              }
            },
            '2014.03' => {
              '5.1' => {
                'package_name' => 'mysql51-server'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server'
              }
            }
          },
          'fedora' => {
            '19' => {
              '5.5' => {
                'package_name' => 'community-mysql-server'
              }
            },
            '20' => {
              '5.5' => {
                'package_name' => 'community-mysql-server'
              }
            }
          },
          'suse' => {
            '11.3' => {
              '5.5' => {
                'package_name' => 'mysql'
              }
            }
          },
          'debian' => {
            '6' => {
              '5.1' => {
                'package_name' => 'mysql-server-5.1'
              }
            },
            '7' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              }
            },
            'jessie/sid' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              }
            },
            '10.04' => {
              '5.1' => {
                'package_name' => 'mysql-server-5.1'
              }
            },
            '12.04' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              }
            },
            '13.04' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              }
            },
            '13.10' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              }
            },
            '14.04' => {
              '5.5' => {
                'package_name' => 'mysql-server-5.5'
              },
              '5.6' => {
                'package_name' => 'mysql-server-5.6'
              }
            }
          },
          'smartos' => {
            '5.11' => {
              '5.5' => {
                'package_name' => 'mysql-server'
              },
              '5.6' => {
                'package_name' => 'mysql-server'
              }
            }
          },
          'omnios' => {
            '151006' => {
              '5.5' => {
                'package_name' => 'database/mysql-55'
              },
              '5.6' => {
                'package_name' => 'database/mysql-56'
              }
            }
          },
          'freebsd' => {
            '9' => {
              '5.5' => {
                'package_name' => 'mysql55-server'
              }
            },
            '10' => {
              '5.5' => {
                'package_name' => 'mysql55-server'
              }
            }
          }
        }
      end
    end
  end
end

##############
# END OF CRUFT
##############

module MysqlCookbook
  module Helpers
    # FIXME: refactor into common lib
    def try_really_hard(query, database)
      info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass} -D #{database} --skip-column-names")
      return info.stdout.chomp if info.exitstatus == 0
      info = shell_out("echo \"#{query}\" | #{mysql_w_network_stashed_pass} -D #{database} --skip-column-names")
      return info.stdout.chomp if info.exitstatus == 0
      info = shell_out("echo \"#{query}\" | #{mysql_w_socket_resource_pass} -D #{database} --skip-column-names")
      return info.stdout.chomp if info.exitstatus == 0
      info = shell_out("echo \"#{query}\" | #{mysql_w_socket_stashed_pass} -D #{database} --skip-column-names")
      return info.stdout.chomp if info.exitstatus == 0
      info = shell_out("echo \"#{query}\" | #{mysql_w_socket} -D #{database} --skip-column-names")
      return info.stdout.chomp if info.exitstatus == 0
      false
    end

    def repair_root_password
      query = "UPDATE mysql.user SET Password=PASSWORD('#{new_resource.parsed_root_password}')"
      query << " WHERE User='root'; FLUSH PRIVILEGES;"
      try_really_hard(query, 'mysql')
    end

    def test_root_acl(acl)
      query = "SELECT Host,User,Password FROM mysql.user WHERE User='root' AND Host='#{acl}';"
      info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
      return false unless info.exitstatus == 0
      return false if info.stdout.empty?
      true
    end

    def repair_root_acl(acl)
      query = " GRANT ALL PRIVILEGES ON *.* TO 'root'@'#{acl}'"
      query << " IDENTIFIED BY '#{new_resource.parsed_root_password}' WITH GRANT OPTION;"
      try_really_hard(query, 'mysql')
    end

    def test_remove_anonymous_users
      query = "SELECT * FROM user WHERE User=''"
      try_really_hard(query, 'mysql')
    end

    def repair_remove_anonymous_users
      query = "DELETE FROM user WHERE User=''"
      try_really_hard(query, 'mysql')
    end

    def test_repl_acl(acl)
      query = "SELECT Host,User,Password FROM mysql.user WHERE User='repl' AND Host='#{acl}';"
      info = shell_out("echo \"#{query}\" | #{mysql_w_network_resource_pass}")
      return false unless info.exitstatus == 0
      return false if info.stdout.empty?
      true
    end

    def repair_repl_acl(acl)
      query = " GRANT REPLICATION SLAVE ON *.* TO 'repl'@'#{acl}' "
      query << " IDENTIFIED BY '#{new_resource.parsed_repl_password}';"
      try_really_hard(query, 'mysql')
    end

    def repair_repl_acl_extras
      query = "DELETE FROM mysql.user WHERE User='repl'"
      query << " AND Host NOT IN ('#{new_resource.repl_acl.join('\', \'')}');"
      try_really_hard(query, 'mysql')
    end

    def repair_root_acl_extras
      query = "DELETE FROM mysql.user WHERE User='root'"
      query << " AND Host NOT IN ('#{new_resource.root_acl.join('\', \'')}');"
      try_really_hard(query, 'mysql')
    end
  end
end
