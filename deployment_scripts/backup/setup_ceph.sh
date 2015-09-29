#!/bin/bash

replaced_node=$(hostname -s)
ceph_conf="/etc/ceph/ceph.conf"
  working_node=$1
yum -y --quiet install ceph-common librados2 python-ceph ceph-deploy ceph-radosgw libcephfs1 ceph
declare -x cluster_network=$(awk '{ if ($1 == "cluster_network") print $3; }' $ceph_conf)
declare -x public_network=$(awk '{ if ($1 == "public_network") print $3; }' $ceph_conf)
rm -rf /etc/ceph/
scp -r $working_node:/etc/ceph/ /etc/
sed -i "s|`cat $ceph_conf | grep -w host`|host = $replaced_node|g" $ceph_conf
sed -i "s|`cat $ceph_conf | grep -w cluster_network`|cluster_network = $cluster_network|g" $ceph_conf
sed -i "s|`cat $ceph_conf | grep -w public_network`|public_network = $public_network|g" $ceph_conf
rm -rf /var/lib/ceph/mon/*
rm -f /var/lib/ceph/bootstrap-{osd,mds}/ceph.keyring
