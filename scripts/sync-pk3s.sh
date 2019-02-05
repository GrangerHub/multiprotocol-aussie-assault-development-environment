#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

for i in $HOMEPATH/*/

do
  gamename=$(basename $i)
  rsync -rauv --progress -e 'ssh' $i/*.pk3 $WEB_PK3_SSH_REMOTE_SERVER:${WEB_PK3_SSH_REMOTE_SERVER_PATH}/$gamename
done
