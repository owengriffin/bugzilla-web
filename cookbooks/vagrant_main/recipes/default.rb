require_recipe "bugzilla"
# require_recipe "apache2"
# include_recipe "php::php5"
# require_recipe "mysql::server"
# apache_module "rewrite"
# apache_module "proxy"

# # Disable the existing Apache2 site
# execute "disable-default-site" do 
#   command "a2dissite default"
#   only_if do File.exists?("/etc/apache2/sites-enabled/000-default") end
#   notifies :restart, resources(:service => "apache2")
#   action :run
# end

# web_app "nape" do
#   docroot node[:joomla][:path]
#   template "joomla.conf.erb"
#   server_name node[:fqdn]
#   server_aliases [node[:hostname], "joomla"]
# end

# remote_file "/tmp/joomla.zip" do
#   source "http://joomlacode.org/gf/download/frsrelease/12193/49780/Joomla_1.5.17-Stable-Full_Package.zip"
#   mode "0644"
#   not_if do
#     File.exists? "/tmp/joomla.zip"
#   end
# end

# execute "extract-joomla" do
#   command "unzip -d #{node[:joomla][:path]} /tmp/joomla.zip"
#   not_if do
#     File.exists? node[:joomla][:path]
#   end
# end

# Gem.clear_paths
# require 'mysql'

# execute "create #{node[:joomla][:db][:database]} database" do
#   command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:joomla][:db][:database]}"
#   not_if do
#     m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
#     m.list_dbs.include?(node[:joomla][:db][:database])
#   end
# end

# execute "mysql-install-privileges" do
#   command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/grants.sql"
#   action :nothing
# end

# template "/etc/mysql/grants.sql" do
#   source "grants.sql.erb"
#   owner "root"
#   group "root"
#   mode "0600"
#   variables(
#     :user     => node[:joomla][:db][:user],
#     :password => node[:joomla][:db][:password],
#     :database => node[:joomla][:db][:database]
#   )
#   notifies :run, resources(:execute => "mysql-install-privileges"), :immediately
# end

# execute "generate-prefix-sql" do
#   command "sed -i 's/\#__/#{node[:joomla][:db][:prefix]}/g' /vagrant/joomla/installation/sql/mysql/joomla.sql > /vagrant/joomla_#{node[:joomla][:db][:prefix]}.sql"
#   not_if do
#     File.exists?("/vagrant/joomla_#{node[:joomla][:db][:prefix]}.sql")
#   end
# end

# execute "install-default-schema" do
#   command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /vagrant/joomla_#{node[:joomla][:db][:prefix]}.sql"
#   action :nothing
# end

# template "/vagrant/joomla/configuration.php" do
#   source "configuration.php.erb"
#   owner "www-data"
#   group "www-data"
#   mode "0644"
#   variables(:params => { 
#               :email_address => node[:joomla][:email_address],
#               :sitename => node[:joomla][:name],
#               :table_prefix => node[:joomla][:db][:prefix],
#               :mysql_user => node[:joomla][:db][:user],
#               :mysql_password => node[:joomla][:db][:password],
#               :mysql_database => node[:joomla][:db][:database]
#             })
# end
