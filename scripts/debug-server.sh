#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

gdb -ex run --args "$OVERPATH/tremded" \
    +set com_ansiColor 1 \
    +set sv_pure "$SV_PURE" \
    +set vm_game "$VM_GAME" +set vm_cgame "$VM_CGAME" +set vm_ui "$VM_UI" \
    +set fs_basegame "$BASEGAME" \
    +set fs_game "$GAME" \
    +set sv_master1 "master.tremulous.net" \
    +set sv_alt1master1 "master.tremulous.net" \
    +set sv_alt2master1 "master.tremulous.net" \
    +set sv_master2 "master.grangerhub.com" \
    +set sv_alt1master2 "master.grangerhub.com" \
    +set sv_alt2master2 "master.grangerhub.com" \
    +set sv_dlURL "$DOWNLOAD_URL" \
    +set fs_overpath "$OVERPATH" \
    +set fs_basepath "$BASEPATH" \
    +set fs_homepath "$HOMEPATH" \
    +set dedicated 2 \
    +set fs_pk3PrefixPairs "&vms-1.1.0|vms-gpp1&" \
    +set net_alternateProtocols 3 \
    +set net_port $NET_PORT +set net_alt1port $NET_ALT1_PORT +set net_alt2port $NET_ALT2_PORT \
    +set sv_allowDownload 3 \
    +exec server.cfg \
    +map atcs
