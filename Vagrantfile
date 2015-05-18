# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "wmit/trusty64"
  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--memory", 1024]
  end
  config.vm.synced_folder "", "/vagrant", create: true
  config.vm.provision "shell", path: "./pre-puppet.sh"
  config.vm.provision :puppet do |puppet|
    puppet.hiera_config_path = "hiera.yaml"
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "site.pp"
    puppet.options = [
      "--pluginsync",
      "--debug"
    ]
  end
  config.vm.provision "shell", path: "./post-puppet.sh"
end
