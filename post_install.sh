#!/bin/bash

DEBUG=true
DIR=`dirname ${BASH_SOURCE[0]}`

FUEL='/usr/bin/fuel'
REL=`$FUEL rel | grep -i ubuntu | awk '{print $1}'`
FUEL_REL=`$FUEL rel | grep -i ubuntu | awk '{print $NF}'`

function debug {
  if $DEBUG; then
    echo $@
  fi
}

function set_min_controller_count {
  count=$1
  workdir=$(mktemp -d /tmp/modifyenv.XXXX)
  $FUEL role --rel $REL --role controller --file $workdir/controller.yaml
  sed -i "s/    min: ./    min: ${count}/" $workdir/controller.yaml
  $FUEL role --rel $REL --update --file $workdir/controller.yaml
  rm -rf $workdir
}

set_min_controller_count 0
cp -a ${DIR}/deployment_scripts/backup /etc/puppet/$FUEL_REL/modules/osnailyfacter/modular/
$FUEL rel --sync-deployment-tasks --dir /etc/puppet/$FUEL_REL

