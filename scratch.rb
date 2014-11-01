# action :wat do
#   # set root password
#   ruby_block "#{new_resource.parsed_name} :create repair_root_password" do
#     block { repair_root_password }
#     not_if { test_root_password }
#     action :run
#     notifies :create, "file[#{new_resource.parsed_name} :create #{etc_dir}/.mysql_root]"
#   end

#   file "#{new_resource.parsed_name} :create #{etc_dir}/.mysql_root" do
#     path "#{etc_dir}/.mysql_root"
#     mode '0600'
#     content new_resource.parsed_root_password
#     action :nothing
#   end

#   # repair root ACL
#   new_resource.root_acl.each do |acl|
#     ruby_block "#{new_resource.parsed_name} :create root_acl #{acl}" do
#       block { repair_root_acl acl }
#       not_if { test_root_acl acl }
#       notifies :run, "ruby_block[#{new_resource.parsed_name} :create root_acl_extras]"
#       action :run
#     end
#   end

#   ruby_block "#{new_resource.parsed_name} :create root_acl_extras" do
#     block { repair_root_acl_extras }
#     action :nothing
#   end

#   # remove anonymous_users
#   ruby_block "#{new_resource.parsed_name} :create repair_remove_anonymous_users" do
#     block { repair_remove_anonymous_users }
#     not_if { test_remove_anonymous_users }
#     only_if { new_resource.parsed_remove_anonymous_users }
#     action :run
#   end

#   # repair repl ACL
#   new_resource.repl_acl.each do |acl|
#     ruby_block "#{new_resource.parsed_name} :create repl_acl #{acl}" do
#       block { repair_repl_acl acl }
#       not_if { test_repl_acl acl }
#       notifies :run, "ruby_block[#{new_resource.parsed_name} :create repl_acl_extras]"
#       action :run
#     end
#   end

#   ruby_block "#{new_resource.parsed_name} :create repl_acl_extras" do
#     block { repair_repl_acl_extras }
#     action :nothing
#   end
# end
