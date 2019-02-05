#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../.config-defaults.sh

die() {
	echo -e "\e[31m$@\e[0m"
	exit 1
}

chmod u+x $DEV_ENV_PATH/scripts/update.sh
chmod u+x $DEV_ENV_PATH/scripts/run-server.sh
chmod u+x $DEV_ENV_PATH/scripts/debug-server.sh
chmod u+x $DEV_ENV_PATH/scripts/sync-pk3s.sh
chmod u+x $DEV_ENV_PATH/scripts/rotate-game-logs.sh
chmod u+x $DEV_ENV_PATH/scripts/package-assets.sh
chmod u+x $DEV_ENV_PATH/scripts/scrub-game-log.sh

mkdir -p $HOMEPATH
mkdir -p "$HOMEPATH/base"

cp $DEV_ENV_PATH/.config-defaults.sh $DEV_ENV_PATH/config.sh || die init failed
