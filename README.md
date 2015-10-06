Fuel infrastructure plugin
===================

This plugin is designed for Mirantis Openstack (Fuel) 6.1, for Ubuntu. It is creates backups of sensitive cloud data. 
1. ETC Backup from cloud-nodes. Just to have information about all nodes in case of disaster recovery.
2. FUEL-backup. The necessity of this to have information about all cloud nodes their roles and configuration. To have ability to add/remove nodes, manage clusters.
3. CEPH-RBD incrimental backup(if enabled as a storage). When we use ceph-rbd for all cloud needs such as volumes, images, ephemeral storages in couple with mysql db backup, we have full information about all virtual storages, and have ability to restore cloud in case of disaster. 
4. MySQL db backup.


