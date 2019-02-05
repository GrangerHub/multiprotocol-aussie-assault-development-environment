#!/bin/bash

SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
SCRIPTPATH=`dirname "$SCRIPT"`

source $SCRIPTPATH/../config.sh

Update_Tremded() {
    if [[ ! -d $ENGINE_SRC ]]; then
        pushd $PATCHES
        git clone $ENGINE_REPO
        pushd $ENGINE_REPO
        git checkout $ENGINE_BRANCH
        popd
        popd
    fi

    pushd $ENGINE_SRC
    make clean
    rm -rf build
    make -j 2 debug
    popd

    if [[ -e "$OVERPATH/tremded" ]]; then
        cp $OVERPATH/tremded $OVERPATH/tremded.old
    fi

    cp $ENGINE_SRC/build/debug-linux-x86_64/tremded $OVERPATH/tremded
}

Update_GameLogic() {
    if [[ ! -d $QVM_SRC ]]; then
        pushd $PATCHES
        git clone $QVM_REPO
        pushd $ENGINE_REPO
        git checkout $QVM_BRANCH
        popd
        popd
    fi

    pushd $QVM_SRC
    make clean
    rm -rf bld
    make -j 2 debug
    popd

    QVM_MINOR_DIFF_BASE_HASH=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" rev-parse HEAD 2>&1)

    NO_QVM_GIT_TAG="false"
    QVM_GIT_TAG=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" describe --tags --abbrev=0 2>&1) || NO_QVM_GIT_TAG=true
    if [ "$NO_QVM_GIT_TAG" = "true" ]; then
      QVM_MAJOR_DIFF_BASEHASH=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" rev-parse HEAD^ 2>&1)
    else
      QVM_MAJOR_DIFF_BASEHASH=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" rev-list -n 1 "$QVM_GIT_TAG" 2>&1)
    fi

    QVM_GIT_VERSION=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" rev-parse --short HEAD 2>&1)

    pushd "$DEV_ENV_PATH"
    mkdir -p "$DEV_ENV_PATH/version-log"
    popd
    pushd "$DEV_ENV_PATH/version-log"
    mkdir -p "$GAME"
    popd
    pushd "$DEV_ENV_PATH/version-log/$GAME"
    if [ ! -e "$DEV_ENV_PATH/version-log/$GAME/src-build-version-number-DO-NOT-EDIT.txt" ]; then
        echo "0" > "$DEV_ENV_PATH/version-log/$GAME/src-build-version-number-DO-NOT-EDIT.txt"
    fi

    n="$(cat "$DEV_ENV_PATH"/version-log/"$GAME"/src-build-version-number-DO-NOT-EDIT.txt)" || exit 1
    test "$n" -ge 0 && test "$n" -lt 9999 || { echo 'x/q: the build number is invalid' >&2 ; exit 1 ; }
    n="$((n + 1))"
    m="$(printf '%04u\n' "$n")"

    QVMVERSION="$GAME-$m-$QVM_GIT_VERSION"
    mkdir -p "$QVM_GIT_VERSION"
    popd
    pushd "$DEV_ENV_PATH/version-log/$GAME/$QVM_GIT_VERSION"
    mkdir -p "bin-$QVMVERSION"
    BUILD_VERSION_LOGPATH="$DEV_ENV_PATH/version-log/$GAME/$QVM_GIT_VERSION/bin-$QVMVERSION"
    popd
    pushd "$BUILD_VERSION_LOGPATH"

    rm -f $HOMEPATH/"$GAME"/vms-*.pk3

    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVM_BLDOUT_DIR_PREFIX-$QVM_GIT_VERSION.pk3" "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" || exit 1
    cp "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVM_BLDOUT_DIR_PREFIX-$QVM_GIT_VERSION.pk3" "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" || exit 1

    git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" diff "$QVM_MAJOR_DIFF_BASEHASH" > "$QVMVERSION-major.patch"
    for next in $( git ls-files --others --exclude-standard ) ; do
        DIFF_SEGMENT=$(git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" --no-pager diff --no-index /dev/null $next 2>&1);
        echo "$DIFF_SEGMENT" >> "$QVMVERSION-major.patch"
    done;
    zip -rX9 "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" "$QVMVERSION-major.patch"
    zip -rX9 "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" "$QVMVERSION-major.patch"

    

    git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" diff "$QVM_MINOR_DIFF_BASE_HASH" > "$QVMVERSION-minor-working.patch"
    for next in $( git ls-files --others --exclude-standard ) ; do
        git --git-dir "$QVM_SRC/.git" --work-tree "$QVM_SRC" --no-pager diff --no-index /dev/null "$next" > "$QVMVERSION-minor-working-temp.patch";
        combinediff 
    done;
    zip -rX9 "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" "$QVMVERSION-minor-working.patch"
    zip -rX9 "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" "$QVMVERSION-minor-working.patch"
    popd

    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/game.so" "$HOMEPATH/$GAME/"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/game.so" "$BUILD_VERSION_LOGPATH/"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/cgame.so" "$HOMEPATH/$GAME/"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/cgame.so" "$BUILD_VERSION_LOGPATH/"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/ui.so" "$HOMEPATH/$GAME/"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/ui.so" "$BUILD_VERSION_LOGPATH/"
    pushd "$QVM_SRC"
    zip -rX9 "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" GPL
    cp "$QVM_SRC/README" "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/" || exit 1
    echo -e "\nMajor patches are based on commit hash $QVM_MAJOR_DIFF_BASEHASH" >> "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/README"
    echo "Minor working directory patches are based on commit hash $QVM_MINOR_DIFF_BASE_HASH" >> "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/README"
    popd
    pushd "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/"
    zip -rX9 "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" README
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" "$HOMEPATH/$GAME/vms-gpp1-$QVMVERSION.pk3"
    cp "$QVM_BLDOUTPATH/$QVM_BLDOUT_DIR_PREFIX/vms-gpp1-$QVMVERSION.pk3" "$BUILD_VERSION_LOGPATH/vms-gpp1-$QVMVERSION.pk3"
    popd

    pushd "$QVM_SRC"
    zip -rX9 "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" GPL
    cp "$QVM_SRC/README" "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/" || exit 1
    echo -e "\nMajor patches are based on commit hash $QVM_MAJOR_DIFF_BASEHASH" >> "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/README"
    echo "Minor working directory patches are based on commit hash $QVM_MINOR_DIFF_BASE_HASH" >> "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/README"
    popd
    pushd "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/"
    zip -rX9 "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" README
    cp "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" "$HOMEPATH/$GAME/vms-1.1.0-$QVMVERSION.pk3"
    cp "$QVM_BLDOUTPATH/${QVM_BLDOUT_DIR_PREFIX}_11/vms-1.1.0-$QVMVERSION.pk3" "$BUILD_VERSION_LOGPATH/vms-1.1.0-$QVMVERSION.pk3"
    popd

    cp -n $BASEPATH/base/server.cfg $HOMEPATH/$GAME/

    echo "$n" > "$DEV_ENV_PATH/version-log/$GAME/src-build-version-number-DO-NOT-EDIT.txt"

    cp $OVERPATH/tremded "$BUILD_VERSION_LOGPATH/"
}

pushd "$DEV_ENV_PATH"
mkdir -p "$PATCHES"
mkdir -p "$OVERPATH"
mkdir -p "$HOMEPATH/$GAME"
popd

Update_Tremded
Update_GameLogic
