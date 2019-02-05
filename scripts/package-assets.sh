#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

Package_Assets() {
    if [[ ! -d $QVM_SRC ]]; then
        pushd $PATCHES
        git clone $QVM_REPO
        popd
    fi

    QVM_GIT_VERSION=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" rev-parse --short HEAD 2>&1)

    pushd "$DEV_ENV_PATH"
    mkdir -p "$DEV_ENV_PATH/version-log"
    popd
    pushd "$DEV_ENV_PATH/version-log"
    mkdir -p "$GAME"
    popd
    pushd "$DEV_ENV_PATH/version-log/$GAME"
    if [ ! -e "$DEV_ENV_PATH/version-log/$GAME/assets-version-number-DO-NOT-EDIT.txt" ]; then
        echo "0" > "$DEV_ENV_PATH/version-log/$GAME/assets-version-number-DO-NOT-EDIT.txt"
    fi

    n="$(cat "$DEV_ENV_PATH"/version-log/"$GAME"/assets-version-number-DO-NOT-EDIT.txt)" || exit 1
    test "$n" -ge 0 && test "$n" -lt 9999 || { echo 'x/q: the build number is invalid' >&2 ; exit 1 ; }
    n="$((n + 1))"
    m="$(printf '%04u\n' "$n")"

    ASSETS_VERSION="$GAME-$m-$QVM_GIT_VERSION"
    mkdir -p "$QVM_GIT_VERSION"
    popd
    pushd "$DEV_ENV_PATH/version-log/$GAME/$QVM_GIT_VERSION"
    mkdir -p "assets-$ASSETS_VERSION"
    ASSET_VERSION_LOGPATH="$DEV_ENV_PATH/version-log/$GAME/$QVM_GIT_VERSION/assets-$ASSETS_VERSION"
    popd

    cp "$QVM_SRC/src/ui/menudef.h" "$ASSETSPATH/ui/"
    rm -f $HOMEPATH/$GAME/$ASSETS_PK3_PREFIX-*.pk3

    pushd "$QVM_SRC"
    zip -rX9 "$HOMEPATH/$GAME/$ASSETS_PK3_PREFIX-$ASSETS_VERSION.pk3" README CC
    popd
    pushd "$ASSETSPATH"
    for i in $ASSETSPATH/*

    do
        name=$(basename $i)
        zip -rX9 "$HOMEPATH/$GAME/$ASSETS_PK3_PREFIX-$ASSETS_VERSION.pk3" $name
    done
    cp "$HOMEPATH/$GAME/$ASSETS_PK3_PREFIX-$ASSETS_VERSION.pk3" "$ASSET_VERSION_LOGPATH/"
    popd

    echo "$n" > "$DEV_ENV_PATH/version-log/$GAME/assets-version-number-DO-NOT-EDIT.txt"
}

pushd "$DEV_ENV_PATH"
mkdir -p "$HOMEPATH/$GAME"

Package_Assets
popd
