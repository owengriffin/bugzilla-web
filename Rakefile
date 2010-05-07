require 'rubygems'

begin
   require 'jeweler'
   Jeweler::Tasks.new do |gem|
     # Define the name of the gem
     gem.name = "bugzilla-web"
     gem.summary = %Q{Library for maniupulating Bugzilla by interacting with the web interface.}
     gem.description = %Q{Provides methods for searching and creating bugs. Tested with Bugzilla 3.4.6}
     # Contact information for the author
     gem.email = "email@owengriffin.com"
     gem.homepage = "http://www.owengriffin.com/"
     gem.authors = ["Owen Griffin"]
     # Runtime dependencies
     gem.add_dependency "mechanize", ">= 0.9.3"
     gem.add_development_dependency "cucumber", ">= 0.7.2"
   end
   Jeweler::GemcutterTasks.new
   rescue LoadError
     puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'cucumber'
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end
rescue LoadError
  puts "Cucumber not available. Install it with: gem install cucumber"
end

task :default => [:features, :build]
