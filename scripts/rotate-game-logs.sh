#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

chmod o-rwx "$HOMEPATH/$GAME/games.log"

umask 0077

timestamp=$(date --date="yesterday" +%Y%m%d)
zipfile="$LOGPATH/$(whoami)-${timestamp}.zip"
scrubbed_zipfile="$SCRUBBED_LOGPATH/$(whoami)-${timestamp}.zip"

if [ -f "$zipfile" ]; then
  exit 1
fi

mkdir -p "$LOGPATH" "$SCRUBBED_LOGPATH"

# move files to a temporary location to prevent a race condition that could
# occur if we zipped the files in place and truncted them after
mkdir -p "$HOMEPATH/$GAME/tmp"
mv "$HOMEPATH/$GAME/admin.log" "$HOMEPATH/$GAME/games.log" "$HOMEPATH/$GAME/tmp"
#cp "$HOMEPATH/$GAME/admin.log" "$HOMEPATH/$GAME/games.log" "$HOMEPATH/$GAME/tmp"
touch "$HOMEPATH/$GAME/admin.log" "$HOMEPATH/$GAME/games.log"

cd "$HOMEPATH/$GAME/tmp"
zip -qX9 "$zipfile" admin.log games.log
grep -ve '^[ 0-9]\{3\}:[0-9]\{2\} privmsg: ' games.log > games.log.temp
mv games.log.temp games.log
zip -qX9 "$scrubbed_zipfile" games.log
cd ..
rm -r "$HOMEPATH/$GAME/tmp"

cd "$LOGPATH"
shopt -s nullglob
delete=$(ls -1 $(whoami)-*.zip | head -n -${LOGDAYS})
for f in $delete; do
  rm "$f"
done

cd "$SCRUBBED_LOGPATH"
delete=$(ls -1 $(whoami)-*.zip | head -n -${LOGDAYS})
for f in $delete; do
  rm "$f"
done

chgrp $GAME_ADMIN_GROUP_NAME "$LOGPATH"
chmod g+x "$LOGPATH"

chgrp -R $GAME_ADMIN_GROUP_NAME "$SCRUBBED_LOGPATH"
chmod -R g+r "$SCRUBBED_LOGPATH"
chmod g+x "$SCRUBBED_LOGPATH"
