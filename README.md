# Openhab2 automated install and migration to vagrant box

My goal for this project is to migrate from old to a new smarthome server with all the settings and applications running.
The target setup is to have: openhab2.2 + influxdb for persistence + grafana monitoring + vcontrol for viessmann heating + zoneminder for cameras
The installation is done in 2 steps for each piece:
- necessary packages and settings are deployed
- configuration is restored from backup

## Getting Started

### Prerequisites

Roles included in the playbook use backup files that have been already taken from server to be migrated.
Execute the backups by using the following scripts and tutorials:

[openhab2 backup](https://www.openhab.org/docs/installation/linux.html)
```
example:
sudo $OPENHAB_RUNTIME/bin/backup
```
[influxdb backup](https://www.influxdata.com/blog/new-features-in-open-source-backup-and-restore)
```
example:
influxd backup -portable /tmp/backup_file
```
[zoneminder backup](https://forums.zoneminder.com/viewtopic.php?t=17315)
```
example:
sudo docker exec db /usr/bin/mysqldump -u user --password=pass zm > backup.sql
```

There is also secrets.yml file(not included in this repo) with defined credential variables that need to be filled with your own users/passwords for those apps.
remaining packages will get installed by executing selected roles

### Installing

1. Install packages
* [vagrant](https://www.vagrantup.com/)
* [ansible](https://docs.ansible.com/ansible/2.7/installation_guide/intro_installation.html)
2. Download [Vagrantfile](https://github.com/krzysztofrrr/smarthome-ansible/blob/master/openhabvm/Vagrantfile) and put to a folder from which you would like to start VM Box and
3. modify the the lines in the file to fit your environment needs

to use your ssh private key
```
config.ssh.insert_key = false
config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
```

I use a public network to run a box on a different ip address than my host machine

```
config.vm.network "public_network", ip: "<your IP address>", bridge: "eno1"
```

The following lines should be removed in case you don't need to use a vcontrol

```
vb.customize ["modifyvm", :id, "--usb", "on"]
vb.customize ['usbfilter', 'add', '4', '--target', :id, '--name', 'VIES', '--vendorid', '0x10c4', '--productid', '0xea60']
```
	
4. start VM Box by executing `vagrant up` from the Vagrantfile directory
