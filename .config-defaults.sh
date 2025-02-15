#!/bin/bash

CONFIG_SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
DEV_ENV_PATH=`dirname "$CONFIG_SCRIPT"`

BASEGAME="base"
GAME="aa-qvm"
DOWNLOAD_URL="http://dl.grangerhub.com"

SV_PURE=1

VM_GAME=0
VM_CGAME=2
VM_UI=2

NET_PORT=30720
NET_ALT1_PORT=30721
NET_ALT2_PORT=30722

WEB_PK3_SSH_REMOTE_SERVER="www"
WEB_PK3_SSH_REMOTE_SERVER_PATH="/usr/www/webhostname/dl/"

OVERPATH="$DEV_ENV_PATH/overpath"
BASEPATH="$DEV_ENV_PATH/basepath"
HOMEPATH="$DEV_ENV_PATH/homepath"

GAME_ADMIN_GROUP_NAME="game_server_admins"
LOGPATH="$DEV_ENV_PATH/game-logs"
SCRUBBED_LOGPATH="$LOGPATH/scrubbed"

LOGDAYS=90

PATCHES="$DEV_ENV_PATH/source"

ENGINE_REPO_NAME="tremulous"
ENGINE_REPO="https://github.com/GrangerHub/$ENGINE_REPO_NAME.git"
ENGINE_BRANCH="master"
ENGINE_SRC="$PATCHES/$ENGINE_REPO_NAME"

QVM_REPO_NAME="multiprotocol-aussie-assault"
QVM_REPO="https://github.com/GrangerHub/$QVM_REPO_NAME.git"
QVM_BRANCH="master"
QVM_SRC="$PATCHES/$QVM_REPO_NAME"
QVM_BLDOUT_DIR_PREFIX="aa-qvm"
QVM_BLDOUTPATH="$QVM_SRC/bld/out"

ASSETS_PK3_PREFIX="data"
ASSETSPATH="$QVM_SRC/assets"
