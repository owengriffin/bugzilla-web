#!/usr/bin/env ruby
require 'rubygems'
require 'vagrant'

Vagrant::Environment.load!
env = Vagrant::Environment.load!(Dir.pwd)
env.require_persisted_vm
sshconn = Vagrant::SSH.new(env)
sshconn.execute do |ssh|
  cmd = "cd /tmp/vagrant-chef && sudo chef-solo -c solo.rb -j dna.json"
  ssh.exec!(cmd) do |ch, stream, data|
    puts data
  end
end
