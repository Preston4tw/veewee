# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "centos-6.7-x86_64-minimal.box"
  config.ssh.username = "preston4tw"
  config.ssh.private_key_path = "/Users/Pbennes/.ssh/id_rsa"
  # If the VirtualBox guest additions aren't installed, mounting the default
  # synced_folder fails. This turns it off.
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
