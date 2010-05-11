# Adapted from http://github.com/opscode/rails_infra_repo/blob/master/site-cookbooks/database/attributes/database.rb

bugzilla Mash.new unless attribute?("bugzilla")
bugzilla[:path] = "/usr/local/bugzilla"
# Settings for connection to MySQL database
bugzilla[:db] = Mash.new unless bugzilla.has_key?(:db)
# Table prefix
bugzilla[:db][:user] = "bugzilla" unless bugzilla[:db].has_key?(:user)
bugzilla[:db][:password] = "bugzilla" unless bugzilla[:db].has_key?(:password)
bugzilla[:db][:database] = "bugzilla" unless bugzilla[:db].has_key?(:database)
# The name of the Bugzilla site
bugzilla[:name] = "Bugzilla Installation" 
# Administrator email address
bugzilla[:email_address] = "webmaster@bugzilla.local"
