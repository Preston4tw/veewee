# Install the all-in-one puppet-agent, everything under /opt/puppetlabs
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
yum -y install puppet-agent
echo 'export PATH=$PATH:/opt/puppetlabs/bin' > puppet.sh
