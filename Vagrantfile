# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "jammy" do |jammy|
    jammy.vm.box = "ubuntu/jammy64"

    jammy.vm.network "private_network", ip: "192.168.56.56"
    jammy.vm.synced_folder "data", "/data"
    jammy.vm.synced_folder "scripts", "/scripts"
    jammy.vm.synced_folder "configs", "/configs"

    jammy.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "4096"
    end

    jammy.vm.provision "shell", path: "scripts/install.sh"
  end

end
