vagrant-admin
=============

vagrant administration tools. Create new boxes, upload/download vagrant boxes.



VBoxManage list vms

./create_vagrant_base_box.pl --srcname vagrant-devmachine_default_1417289851884_39127 --dstname devmachine --sharecfg ~/vagrants/vagrant-devmachine/vagrant.cfg


You can add a Vagrantfile information to you box package operation by either:
 --vagrantfil MY_VAGRANT_FILE
or by defining the filename relative to the --sharecfg file
 And having the following entry in that shared.cfg file:
VagrantfileRelativeToSharCfg: VagrantPortConfiguration.txt


# register the box
$ vagrant box add http://10.1.2.3/storage/vagrant/srv-fedora-heisenbug64.json

# init the box (this creates a .vagrant folder and a Vagrantfile in the cwd with the appropriate box name)
$ vagrant init company/srv-fedora-heisenbug64



==== VagrantPortConfiguration.txt ====
Vagrant::Config.run do |config|
  # Tomcat
  config.vm.forward_port 8080, 8080
  # Sonar
  config.vm.forward_port 9000, 9000
  # postgresql - used for sonar-runner
  config.vm.forward_port 5432, 5432
end



# Troubleshooting

==== undefined local variable or method `config' for main:Object ====
vagrant up
There was an error loading a Vagrantfile. The file being loaded
and the error message are shown below. This is usually caused by
a syntax error.

Path: /home/cadm/.vagrant.d/boxes/local-VAGRANTSLASH-devmachine/0.1.0/virtualbox/Vagrantfile
Message: undefined local variable or method `config' for main:Object


==== ====
vagrant up
There were warnings and/or errors while loading your Vagrantfile
for the machine 'default'.

Your Vagrantfile was written for an earlier version of Vagrant,
and while Vagrant does the best it can to remain backwards
compatible, there are some cases where things have changed
significantly enough to warrant a message. These messages are
shown below.

Warnings:
* Unknown network type 'forwarded_port' will be ignored.
* Unknown network type 'forwarded_port' will be ignored.
* Unknown network type 'forwarded_port' will be ignored.

