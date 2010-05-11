# Adapted from http://github.com/opscode/rails_infra_repo/blob/master/site-cookbooks/database/attributes/database.rb

chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

joomla_password = ""
20.times { |i| joomla_password << chars[rand(chars.size-1)] }
#root_password = ""
#20.times { |i| root_password << chars[rand(chars.size-1)] }

#mysql Mash.new unless attribute?("mysql")
#mysql[:server_root_password] = root_password
joomla Mash.new unless attribute?("joomla")
joomla[:path] = "/usr/local/joomla"
# Settings for connection to MySQL database
joomla[:db] = Mash.new unless joomla.has_key?(:db)
# Table prefix
joomla[:db][:prefix] = "jom_" unless joomla[:db].has_key?(:prefix)
joomla[:db][:user] = "joomla" unless joomla[:db].has_key?(:user)
joomla[:db][:password] = joomla_password unless joomla[:db].has_key?(:password)
joomla[:db][:database] = "joomla" unless joomla[:db].has_key?(:database)
# The name of the Joomla site
joomla[:name] = "Joomla Installation" 
# Administrator email address
joomla[:email_address] = "webmaster@joomla.local"
