# Openhab2 automated install on vagrant box with migration from earlier openhab releases

This installation was tested with OH2.1, OH2.2 and OH2.4 releases. OH2.4 was the last one I migrated to from OH2.2
The main Purpose for this project was to migrate from old OS and server to a new server with orchestrated installation having all the settings restored and required applications running. It was quite painful to deal with corruptions of SD cards first on Raspberry PI and other issues causing lenghty process of reinstallation and restore of my smarthome server.

The target setup was to have: openhab2.4 + influxdb for persistence + grafana monitoring + vcontrol for viessmann heating + zoneminder for cameras
The installation is done in 2 steps for each piece:
- necessary packages and settings are deployed
- configuration is restored from backup

## Getting Started

### Backup of existing openhab infrastracture

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

### Create secrets file with passwords for grafana and influxdb
Required `secrets.yml` file(not included in this repo) with defined with environment specific credentials for selected apps.

Example content of the `secrets.yml` file:
```
---
# influxdb credentials
influxdb_admin_user: influx_user
influxdb_admin_password: influx_password
influxdb_database_name: openhab_database
influxdb_openhab_user: openhab
influxdb_openhab_password: openhab123
influxdb_grafana_user: grafana
influxdb_grafana_password: grafana123
influxdb_username: "{{ influxdb_openhab_user }}"
influxdb_password: "{{ influxdb_openhab_password }}"

# grafana credentials
grafana_user: admin
grafana_password: admin123

# nginx password
nginx_passwd: nginx_password

```
remaining packages will get installed by executing selected roles
### Copy backup files and secret file to predefined locations
Copy backup files and set correct paths in the `./group_vars/all.yml` file.
Example content:
```
# directories with backups to be restored
backup_directory: "~/openhab-smarthome-server/oh-data"
influxdb_backup_dir: "{{ backup_directory }}/influxdb_backup"
openhab_backup: "{{ backup_directory }}/openhab2backup"
zoneminder_backup: "{{ backup_directory }}/zoneminder/mysql_backup"
secrets_directory: "{{ backup_directory }}/secrets"
```

### Installation

1. Install packages
* [vagrant](https://www.vagrantup.com/)
* [ansible](https://docs.ansible.com/ansible/2.7/installation_guide/intro_installation.html)
2. Download [Vagrantfile](https://github.com/krzysztofrrr/smarthome-ansible/blob/master/openhabvm/Vagrantfile) and put to a folder from which you would like to start VM Box and
3. modify vagrantfiles in ./vagrantfiles folder to fit your environment needs

to use your ssh private key
```
config.ssh.insert_key = false
config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
```

To run a box on a separate ip address than the host machine

```
config.vm.network "public_network", ip: "<your IP address>", bridge: "eno1"
```

To use vcontrol needed to control Viessmann heating

```
vb.customize ["modifyvm", :id, "--usb", "on"]
vb.customize ['usbfilter', 'add', '4', '--target', :id, '--name', 'VIES', '--vendorid', '0x10c4', '--productid', '0xea60']
```
	
4. start VM Box by executing `vagrant up` from the Vagrantfile directory related to your env
```
cd vagrantfiles/openhab-prod
```
or
```
cd vagrantfiles/openhab-test
```

Start the VM
```
vagrant up
```

5. Provision the vm with ansible roles for the selected environment(test or prod)
```
./provision_openhab_vm.sh [test|prod]
```
example:
```
./provision_openhab_vm.sh test
```
## Testing

## Roles included in repo




