#*******************************************************************************
# (c) Copyright 2016 ClearOne
# All Rights Reserved.
#R2.1 - After Hosted or Joined go to home
#*******************************************************************************
#!/bin/sh
. config.sh
. collaborate-space-dist.sh

__ng=/usr/local/lib/node_modules/node/bin/ng

clear
_dist_version=$1
_dist_type=$2
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :: MAIN - INIT - v2.0 - 07/11/2018
echo :: Param 1 Version: $_dist_version
echo :: Param 2 Type: $_dist_type

  if [[ $_dist_type = 'war' ]]
  then
    distWar
  elif [[ $_dist_type = 'backup' ]]
  then
    backup
  elif [[ $_dist_type = 'zip' ]]
  then
    toDist $_PROJECT_DIST-$_zip
  elif [[ $_dist_type = 'web' ]]
  then
    notWarToDist $_PROJECT_DIST.zip webconference
#    notWarToDist $_PROJECT_DIST-$_zip webconference
  elif [[ $_dist_type = 'test' ]]
  then
  frontProdMap
#    backupRemote
  ### Universal Links
  elif [[ $_dist_type = 'ulinks' ]]
  then
    notWarToDist universal-links-$_dist_version.zip universal-links
  else
    distribute $_dist_type
  fi

echo :: MAIN - END
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
