# Development Environment for Multiprotocolized Tremulous 1.1 Servers
This repo is GrangerHub's Development Setup for Multiprotocolized Tremulous 1.1 Servers.  This repo can be used for developing and such multiprotocolized servers.  By default GrangerHub's Multiprotocolized version of Aussie Assault is the game logic source used by this repo.  Additionally GrangerHub's Tremulous 1.3 Engine source is used by default.  The MIT license applies to the included scripts.

*Note: Don't mess with the directory layout nor included hidden files/folders unless you know what you are doing.*

*Note: This Development Environment is only supported for Linux*

# Dependencies and Pre-Installation Prep
Make sure you have installed tmux, git, gdb, zip, bash, and all of the required dependencies to build the engine and game logic sources you will be using.  Additionally make sure that that your system is set to allow core dumps to be saved.

# Installation
Clone this repo to the location what you want to run and develop a server.  

Next initial the Development Environment buy running the init.sh found in the scripts folder:

```
./scripts/init.sh
```

Initialization is only required ones for each Development Environment, and if init.sh is executed again, the Development Environment's config.sh file is reset to the default settings.

After initialization, configure the Development Environment's config.sh file, which would have been automatically generated with default settings into the root of the Development Environment by the initialization process.

After configuration, the first time you run the update.sh script found in the scripts/ folder, the configured repos are cloned into the source/ folder.  After which the engine and game logic are built and installed.

After updating for the first time, run the package-assets.sh script found in the scripts/ folder to package and install the custom assets needed by the game logic.

If you have access to a web host for http downloads of the custom pk3 files, and you configured the variables WEB_PK3_SSH_REMOTE_SERVER_PATH and WEB_PK3_SSH_REMOTE_SERVER, you can sync the new pk3 files generated for your server with the sync-pk3s.sh script found in the scripts/ folder.

Server files such .cfg files, log files, .dat files, map rotation files, and so on would be located in the fs_game (specified in the config.sh file) of the homepath (also specified in the config.sh file).  Put non-default maps in the base folder in the homepath.  All needed default assets are included in the basepath folder, and should not have to be messed with.

It is recommended to use a tmux session to run an instance of a server.  Look up online how to setup and use tmux.

# Configuration
Configuration of the Development environment is handled in the config.sh file.  The variables are as follows:

*BASEGAME*
Specifies the fs_basegame.

*GAME*
Specifies the fs_game.

*DOWNLOAD_URL*
Specifies the url for clients to download pk3 files from.  If you don't have access to a web server you can sync your updated files to, set this variable to:

```
DOWNLOAD_URL=""
```
that would force all clients to download directly from the game server.

*SV_PURE*
This sets sv_pure.  Generally this should be set to 1, otherwise for public servers there tends to be major issues for clients whose doesn't have exactly (no more no less) the required pk3 files and/or dynamic libraries in the current fs_game.  However, to be able to use gdb to debug the cgame and/or ui, their dynamic libraries would have to be loaded instead of their QVMs, and that can only happen if sv_pure is set to 0.  Such debugging is only practical for private testing where you can control the exact contents of the fs_game folders on each connected client without needed pk3 downloads to distribute the files.

*VM_GAME*
This sets vm_game.  To debug the game module with gdb, this would have to be set to 0, and the game.so has to be installed.  The server does not have to have sv_pure set to 0 in order to load the game.so, that is only a requirement of the cgame and ui modules.

*VM_CGAME*
This sets vm_cgame.  See the description for *SV_PURE* 

*VM_UI*
This sets vm_ui.  See the description for *SV_PURE*

*NET_PORT*, *NET_ALT1_PORT*, and *NET_ALT2_PORT*
These set the ports for use by the different protocols.  They must be set to different values for each.  For local lan servers, the ports can only have the values of 30720, 30721, 30722, and/or 30723 to be detected by local clients.

*WEB_PK3_SSH_REMOTE_SERVER*
This refers to the remote server that would be synced to via ssh.  Refer to online references on how to setup and use ssh.

*WEB_PK3_SSH_REMOTE_SERVER_PATH*
This is the path to the specific folder on the remote web server that the pk3 files will be synced to.

*OVERPATH*
This is the folder where the tremded of the game engine would be installed.

*BASEPATH*
This sets the fs_basepath, where the default assets can be found.

*HOMEPATH*
This sets the fs_homepath.

*GAME_ADMIN_GROUP_NAME*
The name of the group that has permission to view the game logs scrubbed of private messages.

*LOGPATH*
The path to the folder that contains the game logs.

*SCRUBBED_LOGPATH*
The path to the folder that contains the game logs that are scrubbed of private messages.

*LOGDAYS*
The number of days for a given day's logs to expire and be automatically deleted.

*PATCHES*
The path to the directory where the source repos and patches are located.

*ENGINE_REPO_NAME*
The name of the game engine's repo.

*ENGINE_REPO*
The url to the game engine's repo that git will use to clone.

*ENGINE_BRANCH*
The branch of the engine repo to start on when it is first cloned.

*ENGINE_SRC*
The path to the game engine repo.

*QVM_REPO_NAME*
The name of the game logic's repo.

*QVM_REPO*
The url to the game logic's repo that git will use to clone.

*QVM_BRANCH*
The branch of the game logic repo to start on when it is first cloned.

*QVM_BLDOUT_DIR_PREFIX*
This is specific to the game logic repo, it corresponds to the BASEGAME specified in the game logic repo's makefile.

*QVM_SRC*
The path to the game logic repo.

*ASSETS_PK3_PREFIX*
THe prefix for the file name of the pk3 containing the custom assets needed by the custom 
ASSETSPATH="$QVM_SRC/assets"

# Scripts
The primary scripts for setting up and operating the Development Environment are included in the scripts/ folder.

*init.sh*
Used to initialize the Development Environment, and to reset the configuration back to default settings.

*update.sh*
Builds the game engine and game logic, and installs the built binaries.  If only the game logic has changes, and the server running while the update occurs, a map change would be enough for the changes to apply.  If however the tremded is changed, a reboot of the tremded would be required.

*package-assets.sh*
Packages and installs the custom assets needed by the game logic.

*sync-pk3s.sh*
Requires WEB_PK3_SSH_REMOTE_SERVER_PATH and WEB_PK3_SSH_REMOTE_SERVER to be properly configured.  If you have ssh access to a web host, you can use this script to sync the custom pk3 files you generated with this Development Environment with the web host to provide http downloads to clients.

*run-server.sh*
Starts an instance of the server based on the configuration specified in config.sh.  It is recommended to execute this script in a tmux session.  If/when the server quits or crashes or otherwise shuts down, after a 5 second delay (if not manually interrupted by a key press) the server will automatically restart.  This script is useful for production servers that should not remain down for long while not supervised.

*debug-server.sh*
Starts an instance of the server in gdb based on the configuration specified in config.sh.  It is recommended to execute this script in a tmux session.  If/when the server quits or crashes or otherwise shuts down, gdb takes control.  This script is good for live debugging of the binaries through gdb, however, while the server is down and gdb has control the server will be unavailable to clients.

*rotate-game-logs.sh*
This archives the previous day's chat and admin logs into a .zip as well as generates a copy with the private messages scrubbed, so that users assigned the user group specified by the variable GAME_ADMIN_GROUP_NAME can review the chat logs without having access to private messages.  It is recommended to setup a cron job to run this script once  each day at midnight.

*scrub-game-log.sh*
This creates a relatively realtime (with a delay up to 5 minutes) copy of the current day's chat and admin logs, with private messages scrubbed so that users assigned the user group specified by the variable GAME_ADMIN_GROUP_NAME can review without access to private messages.  It is recommended to setup a cron job to run this script every 5 minutes.
