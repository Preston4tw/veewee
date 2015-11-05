Veewee::Session.declare({
  :cpu_count => '1',
  # Memory size in MB: 1GB
  # Package selinux-policy-targeted requires 1GB memory during installation
  # https://bugzilla.redhat.com/show_bug.cgi?id=532200
  :memory_size=> '1024',
  # Disk size in MB: 120GB
  :disk_size => '122880',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'RedHat6_64',
  # https://github.com/CentOS/ImageStandards
  # "Images should be based on the minimal distribution"
  :iso_file => "CentOS-6.7-x86_64-minimal.iso",
  # Thank you kernel.org
  :iso_src => "http://mirrors.kernel.org/centos/6.7/isos/x86_64/CentOS-6.7-x86_64-minimal.iso",
  :iso_sha256 => "9d3fec5897be6b3fed4d3dda80b8fa7bb62c616bbfd4bdcd27295ca9b764f498",
  :iso_download_timeout => 1000,
  :boot_wait => "15",
  :boot_cmd_sequence => [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => 300,
  :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "preston4tw",
  :ssh_password => "",
  :ssh_key => "/Users/Pbennes/.ssh/id_rsa",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "sudo sh '%f'",
  # We overload the shutdown command to delete the SSH host keys as well
  :shutdown_cmd => "rm -f /etc/ssh/ssh_host* ; /sbin/halt -h -p",
  :postinstall_files => [
    # Install puppet
    #"puppet.sh",
    # Install ansible
    #"ansible.sh",
    # Customizations for a vagrant box
    #"vagrant.sh",
    # Customizations for a VirtualBox based VM
    "virtualbox.sh",
    # Import the chosen SSH key when instantiating an AMI based on this build
    #"authorized_keys_ec2.sh",
    # In theory: zero out the free space to save space in the final image
    #"zerodisk.sh",
    # Delete log files, clean up yum cache, etc. See file for details
    "cleanup.sh"
  ],
  :postinstall_timeout => 10000
})
