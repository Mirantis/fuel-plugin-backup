#!/bin/bash
# This script used to gather info about cloud. You should provide gathered info to support team.

INFO_PATH=nodes_info
CLEAN_DIR=true
NODES_ADDRESSES=$(fuel node|awk -F'|' '$2~/ready/ && $9~/True/ {gsub(/[ \t]+/, "", $5); print $5;}')

if [ -d "${INFO_PATH}" ]; then
    echo "Deleting old info from ${INFO_PATH} directory..."
    rm -rf ${INFO_PATH}
fi

mkdir ${INFO_PATH}
echo 'Retrieving data from Fuel...'
cd ${INFO_PATH}
for env in $(fuel env|awk -F'|' 'NR>2{gsub(/[ \t]+/, "", $1); print $1;}'); do
    fuel --env ${env} network download
    fuel --env ${env} settings download
    fuel --env 2 provisioning default
done
cd ..

for host in ${NODES_ADDRESSES}; do
    echo "Collecting data from the node ${host}, please wait..."
    ssh -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${host} "bash -c "'
    for f in etc.tar rpm ps services netstat iptables ovs; do rm /tmp/$f; done
    tar -cf /tmp/etc.tar /etc
    if type dpkg >/dev/null 2>&1; then dpkg -l >/tmp/rpm; fi
    if type rpm >/dev/null 2>&1; then rpm -qa >>/tmp/rpm; fi
    ps aux > /tmp/ps
    for serv in $(ls /etc/init.d); do service $serv status >>/tmp/services 2>/dev/null; done 
    netstat -nlp >> /tmp/netstat
    iptables-save >> /tmp/iptables
    ovs-vsctl show > /tmp/ovs
    ovs-dpctl show >> /tmp/ovs
    echo br-int dump-flows >> /tmp/ovs
    ovs-ofctl dump-flows br-int >>/tmp/ovs
    echo br-prv dump-flows >> /tmp/ovs
    ovs-ofctl dump-flows br-prv >> /tmp/ovs
    '" "
    mkdir ${INFO_PATH}/${host}
    # for f in etc.tar rpm ps services netstat iptables ovs; do 
    #     scp $host:/tmp/$f ${INFO_PATH}/$host/
    # done
    echo 'Copying files from the node '${host}
    scp ${host}:"/tmp/etc.tar /tmp/rpm /tmp/ps /tmp/services /tmp/netstat /tmp/iptables /tmp/ovs" ${INFO_PATH}/${host}/
done

tar -czf nodes_info.tar.gz ${INFO_PATH}/
${CLEAN_DIR} && rm -rf ./${INFO_PATH}
