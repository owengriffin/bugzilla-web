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
  mode "0655"
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

require_recipe "perl"

# Install packages which the Debian package for "bugzilla" is dependent on
package "ucf"
package "libtemplate-perl"
package "libappconfig-perl"
package "libemail-send-perl"
package "libmail-sendmail-perl"
package "libemail-mime-perl"
package "libemail-mime-modifier-perl"
package "libemail-mime-perl"
package "libdbd-mysql-perl"
package "ucf"
package "patch"
package "dbconfig-common"

# Install all the modules required by Bugzilla
script "install-modules" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/share/bugzilla-3.4.6/"
  code <<-EOH
  cd /usr/local/share/bugzilla-3.4.6/
/usr/bin/perl install-module.pl CGI
/usr/bin/perl install-module.pl Digest::SHA
/usr/bin/perl install-module.pl DateTime
/usr/bin/perl install-module.pl DateTime::TimeZone
/usr/bin/perl install-module.pl DateTime::Locale
/usr/bin/perl install-module.pl Template
/usr/bin/perl install-module.pl Email::MIME::Encodings
  touch /usr/local/share/bugzilla-3.4.6/install-modules-complete
  EOH
  not_if do
    File.exists? "/usr/local/share/bugzilla-3.4.6/install-modules-complete"
  end
end

execute "create mysql user #{@node[:bugzilla][:db][:user]}" do
  command "echo \"GRANT ALL PRIVILEGES ON *.* TO '#{node[:bugzilla][:db][:user]}'@'localhost' IDENTIFIED BY '#{@node[:bugzilla][:db][:password]}'; flush privileges;\" | /usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    st = m.prepare("select User from mysql.user")
    st.execute
    st.fetch.include?(@node[:bugzilla][:db][:user])
  end
end

ruby_block "create-profiles-table" do
  block do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password], @node[:bugzilla][:db][:database])
    st = m.prepare("CREATE TABLE `profiles` (`userid` mediumint(9) NOT NULL auto_increment, `login_name` varchar(255) NOT NULL, `cryptpassword` varchar(128) default NULL, `realname` varchar(255) NOT NULL default '', `disabledtext` mediumtext NOT NULL, `disable_mail` tinyint(4) NOT NULL default '0', `mybugslink` tinyint(4) NOT NULL default '1', `extern_id` varchar(64) default NULL, PRIMARY KEY  (`userid`), UNIQUE KEY `profiles_login_name_idx` (`login_name`), UNIQUE KEY `profiles_extern_id_idx` (`extern_id`)) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;")
    st.execute
  end
 not_if do    
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])  
    st = m.prepare("select TABLE_NAME from information_schema.tables where table_name = 'profiles';")
    st.execute
    res = st.fetch
    res != nil and res.include?("profiles")
  end
  action :create
end

# Create an administrator user. The default password is "admin"
ruby_block "create-admin-user" do
  block do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password], @node[:bugzilla][:db][:database])
    m.prepare("INSERT INTO `profiles` (`userid`, `login_name`, `cryptpassword`, `realname`, `disabledtext`, `disable_mail`, `mybugslink`, `extern_id`) VALUES (1,'#{@node[:bugzilla][:email_address]}','c2Ig8hHVhtwSd0+gvFNLEG44/jxRFrUL67IVueb7Yuh0wHOiCfc{SHA-256}','Administrator','',0,1,NULL);").execute
  end
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])  
    st = m.prepare("select login_name from bugzilla.profiles")
    st.execute
    res = st.fetch
    res != nil and res.include?(@node[:bugzilla][:email_address])
  end
end

# Ensure that Bugzilla has been correctly setup
execute "check-setup" do
  command "cd /usr/local/share/bugzilla-3.4.6/ ; perl checksetup.pl --make-admin=#{@node[:bugzilla][:email_address]}"
end

# Disable the existing Apache2 site
execute "disable-default-site" do 
  command "a2dissite default"
  only_if do File.exists?("/etc/apache2/sites-enabled/000-default") end
  notifies :restart, resources(:service => "apache2")
  action :run
end

web_app "bugzilla" do
  docroot "/usr/local/share/bugzilla-3.4.6/"
  template "bugzilla_apache.conf.erb"
  server_name node[:fqdn]
  server_aliases [node[:hostname], "bugzilla"]
end
