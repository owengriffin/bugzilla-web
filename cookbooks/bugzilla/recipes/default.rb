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

execute "create mysql user #{@node[:bugzilla][:db][:user]}" do
  command "echo \"create user #{node[:bugzilla][:db][:user]}; SET PASSWORD FOR '#{node[:bugzilla][:db][:user]}'@'%' = PASSWORD('<%= @node[:bugzilla][:db][:password] %>');\" | /usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]}"
  not_if do
    m = Mysql.new("localhost", "root", @node[:mysql][:server_root_password])
    st = m.prepare("select User from mysql.user")
    st.execute
    st.fetch.include?(@node[:bugzilla][:db][:user])
  end
end

require_recipe "perl"

package "ucf"
package "libtemplate-perl"
package "libappconfig-perl"
package "libtimedate-perl"
package "libemail-send-perl"
package "libmail-sendmail-perl"
package "libemail-mime-perl"
package "libemail-mime-modifier-perl"
package "libemail-mime-perl"
#package "libemail-mime-creator-perl"
#package "libcgi-pm-perl"
package "libdbd-mysql-perl"
#package "libdbd-pg-perl"
#package "mail-transport-agent"
package "ucf"
package "patch"
package "dbconfig-common"

script "install-modules" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/share/bugzilla-3.4.6/"
  code <<-EOH
  /usr/bin/perl install-module.pl CGI
  /usr/bin/perl install-module.pl Digest::SHA
  /usr/bin/perl install-module.pl DateTime
  /usr/bin/perl install-module.pl DateTime::TimeZone
  /usr/bin/perl install-module.pl Template
  /usr/bin/perl install-module.pl Email::MIME::Encodings
  EOH
end

execute "check-setup" do
  command "cd /usr/local/share/bugzilla-3.4.6/ ; perl checksetup.pl"
end
