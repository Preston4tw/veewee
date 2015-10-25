# veewee generated EBS backed AWS EC2 HVM CentOS 6 AMI
This repository contains a veewee definition and some scripts to help you
create a CentOS 6 EBS backed AWS EC2 HVM AMI.

# Table of Contents
* [veewee generated EBS backed AWS EC2 HVM CentOS 6 AMI]
  (#veewee-generated-ebs-backed-aws-ec2-hvm-centos-6-ami)
* [Table of Contents](#table-of-contents)
* [Prerequisites](#prerequisites)
* [Getting Started](#getting-started)
  * [Clone this repo](#clone-this-repo)
  * [Tweak some stuff](#tweak-some-stuff)
  * [Build it!](#build-it)
  * [Test it!](#test-it)
  * [Repackage the box as a proper OVA](#repackage-the-box-as-a-proper-ova)
  * [Upload the OVA to S3](#upload-the-ova-to-s3)
  * [Start the import the OVA](#start-the-import-of-the-ova)
  * [Wait for the import to complete](#wait-for-the-import-to-complete)
* [Using the imported AMI](#using-the-imported-ami)
* [Deleting imported AMIs](#deleting-imported-amis)
* [Thanks](#thanks)

# Prerequisites
You will need:
* An [AWS account](https://aws.amazon.com/)
* [awscli](https://aws.amazon.com/cli/)
* [awscli access keys]
  (http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://github.com/mitchellh/vagrant)
* [veewee](https://github.com/jedi4ever/veewee)
* [The VM Import service role configured in AWS]
  (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/VMImportPrerequisites.html#vmimport-service-role)

# Getting started
Once you have everything above:

## Clone this repo
```
git clone https://github.com/Preston4tw/veewee.git
cd veewee/
```

## Tweak some stuff
You would probably rather grant yourself access to the instances you build,
rather than me. This repo is configured to use my username and SSH key. It's
pretty easy to fix that though. Modify the following files, substituting the
username and SSH key you'd like to use. There are some other tweaks you might
also make.
  * definitions/centos-6.kickstart
    * @4-6: If you want to use a different keyboard layout / lang / timezone
    * @60-61: Set the username and public key you want
  * definitions/centos-6.7-x86_64-minimal/definition.rb
    * @8: Disk size: 120GB by default
    * @27,29: The SSH user and private key file to use when running scripts
    * @36-48: Scripts to run after first boot
  * Vagrantfile
    * @10-11: SSH user and private key file

## Build it!
```
# This creates a VirtualBox VM, kickstarts it, and runs the scripts specified in
# definition.rb
veewee vbox build centos-6.7-x86_64-minimal
# This shuts down the created VirtualBox VM and creates
# centos-6.7-x86_64-minimal.box
veewee vbox export centos-6.7-x86_64-minimal
# This removes the created VM from VirtualBox
veewee vbox destroy centos-6.7-x86_64-minimal
```

## Test it!
```
vagrant up && vagrant ssh
```

## Repackage the box as a proper OVA
[Unfortunately the box file isn't OVA compatible.]
(https://github.com/mitchellh/vagrant/issues/322)
Fortunately it's an easy fix:
```
tar -xf centos-6.7-x86_64-minimal.box
tar -cf centos-6.7-x86_64-minimal.ova box.ovf box-disk1.vmdk
# Clean up
rm -f box-disk1.vmdk box.ovf Vagrantfile centos-6.7-x86_64-minimal.box
```

## Upload the OVA to S3
This was glossed over in the Prerequisite section. Turning an OVA into an AMI
happens through the image-import process which requires the VM Import service
role to be configured. To properly configure the role you should have created a
bucket in S3 associated with the policy in the referenced documentation. The OVA
needs to get uploaded into that s3 bucket:
```
aws s3 cp centos-6.7-x86_64-minimal.ova s3://${your-image-import-bucket}
```

## Start the import of the OVA
I've found this process takes about 30 minutes.
```
JSON='
{
    "Description": "centos-6.7-x86_64-netboot.ova",
    "DiskContainers": [
        {
            "Description": "Disk",
            "UserBucket": {
                "S3Bucket": "${your-image-import-bucket}",
                "S3Key": "centos-6.7-x86_64-netboot.ova"
            }
        }
    ]
}
'

# This returns an import-image job id.
aws ec2 import-image --cli-input-json "${JSON}"
```

## Wait for the import to complete
```
aws ec2 describe-import-image-tasks
```

# Using the imported AMI
I just wanted to note that the AMI created by this process is configured **not**
to delete the EBS volume associated with the created instance on termination. If
you're not aware of this then you could end up with a ton of abandoned EBS
volumes. The AWS EC2 API allows you to alter this behavior at instance creation.
General AWS documentation on this can be found [here.]
(http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html#instance-block-device-mapping)
I leave it as an exercise to the reader to figure out how to accomplish that
based on how you create instances. If you're using the awesome [HashiCorp]
(https://hashicorp.com/) tool [terraform](https://terraform.io/) to create
[instances](https://terraform.io/docs/providers/aws/r/instance.html) it's
[really simple]
(https://terraform.io/docs/providers/aws/r/instance.html#delete_on_termination)

# Deleting imported AMIs
If you want to delete an imported AMI, you have to both unregister the AMI as
well as deleting the associated volume snapshot. I typically do this through
the AWS UI but here's how you can do it via awscli:
```
Fill me out
```

# Thanks
This is my favorite section.

Thanks to, in no particular order:
* [GitHub](https://github.com)
  * For hosting all this stuff!
* [Red Hat](http://www.redhat.com/)
  * For without which there would be no CentOS
  * For great documentation
    * [Kickstart Options]
      (https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-kickstart2-options.html)
* [CentOS](https://www.centos.org/) and the awesome community of contributors
  * [CentOS Image Standards](https://github.com/CentOS/ImageStandards)
* [The Amazon AWS team](https://aws.amazon.com/)
  * For setting the high standard by which all other cloud service providers
    are measured.
  * For providing the ability to import VMs into AWS
  * For great documentation
    * [Importing VMs in to AWS]
      (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instances_of_your_vm.html)
* [kernel.org](https://www.kernel.org/)
  * For providing a CentOS mirror
* [@patrickdebois](https://twitter.com/patrickdebois) AKA
  [jedi4ever](https://github.com/jedi4ever)
  * For [veewee](https://github.com/jedi4ever/veewee)
* [hashicorp](https://hashicorp.com/):
  [@mitchellh](https://twitter.com/mitchellh) AKA
  [mitchellh](https://github.com/mitchellh) et al.
  * For [Vagrant](https://github.com/mitchellh/vagrant)
  * For [terraform](https://terraform.io/)
  * And many many many other excellent tools
* [Oracle](http://www.oracle.com/index.html)
  * For [VirtualBox](https://www.virtualbox.org/)
* [@kbsingh](https://twitter.com/kbsingh)
  * For cultivating a great CentOS community
  * [CentOS 7 AMI build info]
    (http://centosfaq.org/centos-virt/centos-7-ami-building/#commentlist)
* [@igordavid](https://twitter.com/igordavid)
  * For [explaning how to change block-device-mappings for an AMI]
    (http://www.cloudhowto.org/changing-block-device-mapping-for-aws-ami/)
* [2creatives](https://github.com/2creatives): [casr](https://github.com/casr) et al.
  * [For making a wicked lean Vagrant CentOS box]
    (https://github.com/2creatives/vagrant-centos/) from which I borrowed a few
    things
* [@joeyespo](https://twitter.com/joeyespo) AKA
  [joeyespo](https://github.com/joeyespo)
  * For [grip](https://github.com/joeyespo/grip), saving me a lot of tiny
    commits to README.md
* [@failvarez](https://twitter.com/failvarez)
  * For general assistance and help with reviews
* [Snowflake Computing](http://www.snowflake.net/) AKA $employer
  * For inspiring this work
