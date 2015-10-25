# Thanks to https://github.com/2creatives/vagrant-centos/
# Cleanup temporary yum files / caches
yum -y clean all

# https://github.com/CentOS/ImageStandards
# "No udev rules from the image build node should be present."
# I think all the hardware specific rules generated by the installer are 70-
rm -f /etc/udev/rules.d/70-*.rules

# ".bash_history should be empty in all accounts."
awk -F: '{ print $6 }' /etc/passwd | while read home_directory; do
  bash_history_file="${home_directory}/.bash_history"
  [ -f "${bash_history_file}" ] && rm -f "${bash_history_file}"
done

# Remove HWADDR and UUID from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i /UUID/d /etc/sysconfig/network-scripts/ifcfg-eth0

# Remove VBoxGuestAdditions ISO
find / -name VBoxGuestAdditions_\*.iso -delete

# Stop services that log before clearing logs
service postfix stop
service rsyslog stop
# Clear logs
rm -f \
  /var/log/anaconda.ifcfg.log \
  /var/log/anaconda.log \
  /var/log/anaconda.program.log \
  /var/log/anaconda.storage.log \
  /var/log/anaconda.syslog \
  /var/log/anaconda.yum.log \
  /root/anaconda-ks.cfg \
  /root/install.log \
  /root/install.log.syslog
echo -n | tee \
  /var/log/cron \
  /var/log/dmesg \
  /var/log/dracut.log \
  /var/log/lastlog \
  /var/log/maillog \
  /var/log/messages \
  /var/log/secure \
  /var/log/wtmp \
  /var/log/yum.log

# Clear tmp
rm -rf /tmp/* /tmp/.[^.]+

# Host SSH keys are deleted by overloading :shutdown_cmd as part of
# definition.rb, which happens when the VM is exported with veewee vbox export:
# Don't uncomment this! It's just to show what is effectively happening
# rm -f /etc/ssh/ssh_host*

# Delete the cleanup script
find / -name cleanup.sh -delete