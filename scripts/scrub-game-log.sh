#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

chmod o-rwx "$HOMEPATH/$GAME/games.log"

umask 0077

mkdir -p "$SCRUBBED_LOGPATH"
grep -ve '^[ 0-9]\{3\}:[0-9]\{2\} privmsg: ' "$HOMEPATH/$GAME/games.log" > "$SCRUBBED_LOGPATH/games.log"
chgrp -R $GAME_ADMIN_GROUP_NAME "$SCRUBBED_LOGPATH"
chmod -R g+r "$SCRUBBED_LOGPATH"
chmod g+x "$SCRUBBED_LOGPATH"
