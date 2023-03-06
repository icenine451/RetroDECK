#!/bin/bash

source /app/libexec/global.sh
source /app/libexec/post_update.sh

# Arguments section

for i in "$@"; do
  case $i in
    -h*|--help*)
      echo "RetroDECK v""$version"
      echo "
      Usage:
flatpak run [FLATPAK-RUN-OPTION] net.retrodeck-retrodeck [ARGUMENTS]

Arguments:
    -h, --help        Print this help
    -v, --version     Print RetroDECK version
    --info-msg        Print paths and config informations
    --configure       Starts the RetroDECK Configurator
    --compress <file> Compresses target file to .chd format. Supports .cue, .iso and .gdi formats.
    --reset-all       Starts the initial RetroDECK installer (backup your data first!)
    --reset-ra        Resets RetroArch's config to the default values
    --reset-sa        Reset all standalone emulator configs to the default values
    --reset-tools     Recreate the tools section

For flatpak run specific options please run: flatpak run -h

https://retrodeck.net
"
      exit
      ;;
    --version*|-v*)
      echo "RetroDECK v$version"
      exit
      ;;
    --info-msg*)
      echo "RetroDECK v$version"
      echo "RetroDECK config file is in: $rd_conf"
      echo "Contents:"
      cat $rd_conf
      exit
      ;;
    --compress*)
      if [[ ! -z $2 ]]; then
      	if [[ -f $2 ]]; then
        	validate_for_chd $2
        else
        	echo "File not found, please specify the full path to the file to be compressed."
        fi
      else
        echo "Please use this command format \"--compress <full path to cue/gdi/iso file>\""
      fi      
      exit
      ;;
    --configure*)
      sh /var/config/retrodeck/tools/configurator.sh
      exit
      ;;
    --reset-ra*)
      ra_init
      shift # Continue launch after previous command is finished
      ;;
    --reset-sa*)
      standalones_init
      shift # Continue launch after previous command is finished
      ;;
    --reset-tools*)
      tools_init
      shift # Continue launch after previous command is finished
      ;;
    --reset-all*)
      rm -f "$lockfile"
      shift # Continue launch after previous command is finished
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

# UPDATE TRIGGERED
# if lockfile exists
if [ -f "$lockfile" ]
then
  # ...but the version doesn't match with the config file
  if [ "$hard_version" != "$version" ];
  then
    echo "Config file's version is $version but the actual version is $hard_version"
    post_update       # Executing post update script
  fi
# Else, LOCKFILE IS NOT EXISTING (WAS REMOVED)
# if the lock file doesn't exist at all means that it's a fresh install or a triggered reset
else
  echo "Lockfile not found"
  finit             # Executing First/Force init
fi

# Normal Startup

start_retrodeck