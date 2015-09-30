#!/bin/bash

DIR=`dirname ${BASH_SOURCE[0]}`

FUEL='/usr/bin/fuel'
REL=`$FUEL rel | grep -i ubuntu | awk '{print $1}'`
FUEL_REL=`$FUEL rel | grep -i ubuntu | awk '{print $NF}'`

rm -rf /etc/puppet/$FUEL_REL/modules/osnailyfacter/modular/backup
$FUEL rel --sync-deployment-tasks --dir /etc/puppet/$FUEL_REL

