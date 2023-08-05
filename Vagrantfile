# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "jammy" do |jammy|
    jammy.vm.box = "ubuntu/jammy64"

    jammy.vm.network "private_network", ip: "192.168.56.56"
    jammy.vm.network "forwarded_port", guest: 80, host: 8888
    jammy.vm.synced_folder "data", "/data"
    jammy.vm.synced_folder "scripts", "/scripts"
    jammy.vm.synced_folder "configs", "/configs"
    jammy.vm.synced_folder "etc/nginx/media_proxy", "/etc/nginx/media_proxy"
    jammy.vm.synced_folder "etc/nginx/sites-available", "/etc/nginx/sites-available"
    jammy.vm.synced_folder "var/www/html", "/var/www/html"

    jammy.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "4096"
    end

    jammy.vm.provision "shell", path: "scripts/install.sh"
  end

end
