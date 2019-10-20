# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = "20180126.0.0"

   # ensure VB Guest is up to date (needs vbguest vagrant plugin to be installed)
  config.vbguest.installer_arguments = "--nox11 -- --force"
  config.vbguest.auto_update = true
  config.vbguest.auto_reboot = true

  # adjust the vm configuration
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    vb.customize ["modifyvm", :id, "--audio", "none", "--usb", "off", "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", File.join(Dir.pwd, "var", "vagrant.log") ]
  end

  config.vm.network "private_network", ip: "192.168.10.10"

  config.vm.synced_folder ".", "/vagrant", :owner => "vagrant", :group => "www-data",mount_options: ["dmode=775,fmode=664"]

  config.vm.provision "shell", path: "vendor/hkwak/qvagrant/stack/provision.sh"
end
