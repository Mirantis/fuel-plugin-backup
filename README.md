Fuel infrastructure backup plugin
===================

Compatible versions:

Mirantis Fuel 6.1
Ubuntu 14.04 server

Purpose
---------------
It creates backups of sensitive cloud data. 

You can change the following options from Fuel UI:
---------------
1. Backup folder location

2. Number copies to store

3. And what to backup:

3.1. ETC Backup from cloud-nodes. Just to have information about all nodes in case of disaster recovery.

3.2. FUEL-backup. It is necessary to have information about all cloud nodes their roles and configuration, and to be able to add/remove nodes, manage clusters.

3.3. CEPH-RBD incremental backup (if enabled as a storage). When we use ceph-rbd for all cloud needs such as volumes, images, ephemeral storages in couple with mysql db backup, we have full information about all virtual storages, and have the ability to restore cloud in case of disaster. 

3.4. MySQL db backup.

Building and installation
===================

How to build plugin:
---------------

You can build plugin using the Fuel plugin builder tool: https://pypi.python.org/pypi/fuel-plugin-builder.

Install fpb Python module:
```
[local-workstation]$ pip install fpb
```

Install system packages fpb module relies on:

* If you use Ubuntu, install packages createrepo rpm dpkg-dev
* If you use CentOS, install packages createrepo dpkg-devel dpkg-dev rpm rpm-build

Clone plugin repository and run fpb there:
```
[local-workstation]$ git clone https://github.com/sheva-serg/fuel-plugin-swift
[local-workstation]$ fpb --build fuel-plugin-swift
```
Check if rpm file was created:
```
[local-workstation]$ ls -al fuel-plugin-swift | grep rpm
-rw-rw-r--.  1 user user 656036 Jun 30 10:57 backup-1.0-1.0.0-1.noarch.rpm
```
Upload rpm file to fuel-master node and install it. Assuming you've put rpm into /tmp directory on fuel-master:
```
[fuel-master]# cd /tmp
[fuel-master]# fuel plugins --install backup-1.0-1.0.0-1.noarch.rpm
```
Check if Fuel sees plugin:
```
[fuel-master]# fuel plugins list
id | name              | version | package_version
---|-------------------|---------|----------------
3  | backup            | 1.0.0   | 2.0.0
```

You can uninstall plugin using the following command:
```
[fuel-master]# fuel plugins --remove backup==1.0.0
```
Please note you can't uninstall the plugin if it is enabled for an environment. You'll have to remove an environment first, this action destroys all stored data and settings for this environment.

Deployment process
===================

1. Create new environment, enable Backup plugin in 'Options' section of environment interface, modify settings if needed.
2. Navigate to 'Nodes' section of UI, press 'Add nodes button'
3. Assign controller/compute roles to the respective nodes.
4. Push Deploy Changes button.
5. After deployment process nn primary-controller node (node with controller role with minimal node-id) will create folder <backup_data_location> that contains folders [etc, fuel, mysql, ceph] (optional) that contains corresponding bash-script that is responsible for creation of each type of backup. At the same moment crontab-rule for running this script once a day(at 4:38, 5:38, 6:38, 7:38) will be created. 
