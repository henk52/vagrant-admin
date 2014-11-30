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
