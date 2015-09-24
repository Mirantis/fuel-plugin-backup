#!/bin/bash

working_node=$1
replaced_node=$(hostname -s)
ceph_conf="/etc/ceph/ceph.conf"

yum -y --quiet install ceph-common librados2 python-ceph ceph-deploy ceph-radosgw libcephfs1 ceph
declare -x cluster_network=$(awk '{ if ($1 == "cluster_network") print $3; }' $ceph_conf)
declare -x public_network=$(awk '{ if ($1 == "public_network") print $3; }' $ceph_conf)
service ceph stop
rm -rf /etc/ceph/
scp -r $working_node:/etc/ceph/ /etc/
sed -i "s|`cat $ceph_conf | grep -w host`|host = $replaced_node|g" $ceph_conf
sed -i "s|`cat $ceph_conf | grep -w cluster_network`|cluster_network = $cluster_network|g" $ceph_conf
sed -i "s|`cat $ceph_conf | grep -w public_network`|public_network = $public_network|g" $ceph_conf
rm -rf /var/lib/ceph/mon/*
rm -f /var/lib/ceph/bootstrap-{osd,mds}/ceph.keyring
#ceph-mon -i $replaced_node --mkfs --keyring /etc/ceph/ceph.client.admin.keyring
scp $working_node:/var/lib/ceph/mon/ceph-$working_node/keyring /var/lib/ceph/mon/ceph-$replaced_node/
#touch /var/lib/ceph/mon/ceph-$replaced_node/{done,sysvinit}
#chown -R apache:apache /etc/ceph/{keyring.radosgw.gateway,nss}
#service ceph restart
#service ceph-radosgw restart
