if ! grep -q '^ec2_ssh_key' /etc/sysconfig/sshd; then
cat >> /etc/sysconfig/sshd <<'EOF'

# Get the AWS EC2 SSH key via instance metadata
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
# The SSH key is inserted into the authorized_keys file of the username
# ($SSH_USER) specified at kickstart time.
# Of note: during image-import AWS boots the AMI and the metadata service 404s.
# -f is needed to prevent inserting garabge into authorized_keys.
ec2_ssh_key="$(curl -f -m1 http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key/ 2>/dev/null)"
if [ $? -eq 0 ]; then
  # Only add the key if not already present
  # The authorized_keys file should have been created during kickstart
  if ! grep -q "${ec2_ssh_key}" ~${SSH_USER}/.ssh/authorized_keys; then
    echo "${ec2_ssh_key}" >> ~${SSH_USER}/.ssh/authorized_keys
  fi
fi
EOF
fi
