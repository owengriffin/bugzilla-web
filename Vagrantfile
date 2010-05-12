Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.provisioner = :chef_solo
  config.chef.cookbooks_path = ["cookbooks"]
  config.vm.forward_port("web", 80, 4567)
  config.chef.log_level = :debug
  config.vm.boot_mode = "gui"
end
