require_recipe "apt"
require_recipe "apache2"

remote_file "/vagrant/bugzilla-3.4.6.tar.gz" do
  source "http://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-3.4.6.tar.gz"
  not_if do
    File.exists? "/vagrant/bugzilla-3.4.6.tar.gz"
  end
end

execute "extract-bugzilla" do
  command "cd /usr/local/share/ ; tar xvf /vagrant/bugzilla-3.4.6.tar.gz"
  not_if do
    File.exists? "/vagrant/bugzilla-3.4.6.tar.gz" and File.directory? "/vagrant/bugzilla-3.4.6.tar.gz"
  end
end

template "/usr/local/share/bugzilla-3.4.6/localconfig" do
  source "localconfig.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :bugzilla => node[:bugzilla]
  )
end

require_recipe "mysql::server"

Gem.clear_paths # needed for Chef to find the gem...
require 'mysql' # requires the mysql gem

execute "create #{node[:bugzilla][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u root -p#{@node[:mysql][:server_root_password]} create #{@node[:bugzilla][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    m.list_dbs.include?(@node[:bugzilla][:db][:database])
  end
end

execute "create mysql user" do
  command "echo \"create user #{node[:bugzilla][:db][:user]}\" | /usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    st = m.prepare("select User from mysql.user")
    st.execute
    st.fetch.include?(@node[:bugzilla][:db][:user])
  end
end
