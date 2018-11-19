#*******************************************************************************
# (c) Copyright 2016 ClearOne
# All Rights Reserved.
#*******************************************************************************
#!/usr/bin/env bash
#. config.sh
#_distName=dist$(date +%Y%m%d%H%M%S).zip


################################################################# COMMAND
__ng=/usr/local/lib/node_modules/node/bin/ng

################################################################# APP
prop="version"
_APP_VERSION="$(node -pe "require('../package.json')['$prop']")"

prop="name"
_APP_NAME="$(node -pe "require('../package.json')['$prop']")"


################################################################# SERVER
_SERVER_VERSIONS_PATH=/home/jesus/versions


### OVERWRITE VALUES
. config.sh

echo PROJECT NAME: $_APP_NAME
echo PROJECT VERSION: $_APP_VERSION
echo SERVER VERSIONS PATH: $_SERVER_VERSIONS_PATH

### 201711091520 ### _distName=dist-$_version.R$1.tar.gz
_distName=$_PROJECT_DIST-$_APP_VERSION
#_distName=$_version.R$1
_dist=$_PROJECT_PATH$_distName
_zip=dist-$_distName.zip
_frontName=$_PROJECT_DIST-$_distName.tar.gz
###_frontName=front-$_distName.tar.gz
_frontServicesName=front-services-$_distName.tar.gz
_apiName=api-$_distName.tar.gz
_dbName=bd-$_distName.tar.gz
_externalName=external-$_distName.tar.gz

_COLOR_BLACK=0
_COLOR_RED=1
_COLOR_GREEN=2
_COLOR_YELLOW=3
_COLOR_BLUE=4
_COLOR_MAGENTA=5
_COLOR_CYAN=6
_COLOR_WHITE=7
_COLOR_DEFAULT=9


function backup()
{
    _file=webapps-$(date +%y%m%d%H%M).zip
    tput setaf $_COLOR_MAGENTA
    echo BACKUP - INIT
    echo File: $_file

        cd /home/jesus
        zip ./backup/$_file webapps/* -r

    echo BACKUP - END
    tput sgr0
}

function backupRemote()
{

  _server=im.collaboratespace.us
  _user=jesus
  _password=One2015!

  echo $_server - backupRemote - INIT

    sshpass -p $_password ssh $_user@$_server "/home/jesus/sh/collaborate-space/dist.sh backup"
#    sshpass -p $_password ssh $_user@$_server command="/home/jesus/sh/collaborate-space/dist.sh backup"

  echo $_server - backupRemote - END
}

function notWarToDist()
{
    _notWarToDist_file=$1
    _notWarToDist_folder=$2

    echo COLLABORATE Space - Web - INIT
    echo File: $_notWarToDist_file

    cd $_PROJECT_PATH
    zip $_notWarToDist_file $_notWarToDist_folder/* -r

    send $_notWarToDist_file

    ### TODO: Install

    echo COLLABORATE Space - Web - END
}

#/root/git/RestApiClient/build.xml
function frontServices()
{
  echo SERVICES API - INIT
    cd $_PROJECT_PATH
    compress $_frontServicesName WebContent
    mv $_frontServicesName $_dist/.
  echo SERVICES API - END
}

function portal4Send()
{
  echo PORTAL4 SEND - $1 - INIT
    cd $_PROJECT_PATH
    sshpass -p .clearone! scp $1 jesus@portal4.spontania.net:/home/jesus
  echo PORTAL4 SEND - $1 - END
}

### 08/06/2018
function collaborate4DevelopSend()
{
  echo collaborate4DevelopSend - INIT
  echo Send: $_distName-$1

    sshpass -p clearone! scp $1 jesus@server.collaborate4d.spontania.net:$_SERVER_VERSIONS_PATH/$_distName-$1

  echo collaborate4DevelopSend - END
}

function collaborate4DevelopInstall()
{
  echo collaborate4DevelopInstall - INIT
  echo Send webapps: $1

    sshpass -p clearone! scp $1 jesus@server.collaborate4d.spontania.net:/home/jesus/webapps

  echo collaborate4DevelopInstall - END
}

function prodSend()
{
  echo www.collaboratespace.net - Send - INIT
    echo Send: $_distName-$1

    sshpass -p One2015! scp $1 jesus@im.collaboratespace.net:/home/jesus/$_distName-$1

  echo www.collaboratespace.net - Send END
}

function prodInstall()
{
  echo www.collaboratespace.net - Install - INIT
    echo Send webapps: $1

    sshpass -p One2015! scp $1 jesus@im.collaboratespace.net:/home/jesus/webapps

  echo www.collaboratespace.net - Install - END
}

#jesus@im.collaboratespace.us
function usSend() {

  _server=im.collaboratespace.us
  _user=jesus
  _password=One2015!

  echo $_server - Send - INIT

    echo Send: $_distName-$1

    sshpass -p $_password scp $1 $_user@$_server:/home/jesus/$_distName-$1

  echo $_server - Send - END

}

function usInstall() {


  _server=im.collaboratespace.us
  _user=jesus
  _password=One2015!

  echo $_server - Install - INIT

    echo Send webapps: $1
    sshpass -p $_password scp $1 $_user@$_server:/home/jesus/webapps

  echo $_server - Install - END

}

function prodSendWar()
{
  echo www.collaboratespace.net SEND - $1 - INIT
    cd $_PROJECT_PATH/war
    sshpass -p One2015! scp $1 jesus@im.collaboratespace.net:/home/jesus
  echo www.collaboratespace.net - $1 - END
}


function collaborate4Send()
{
  echo COLLABORATE4 SEND - $1 - INIT

    echo Send: $_distName-$1

    sshpass -p clearone! scp $1 jesus@server.collaborate4.spontania.net:/home/jesus

  echo COLLABORATE4 SEND - $1 - END
}

function estherSend()
{
  echo ESTHER SEND - $1 - INIT
    sshpass -p clearone! scp $1 root@192.168.1.171:/root
  echo ESTHER SEND - $1 - END
}

function frontDev()
{
  echo FRONTENT DEV - INIT

    cd $_PROJECT_PATH
    rm dist -rf

    $__ng build --base-href $_PROJECT_CONTEXT --configuration=develop

    _zip=$_PROJECT_DIST-dev-$_zip
    toDist $_zip

  echo FRONTENT DEV - END

}

function frontPre()
{
  echo FRONTENT PROD - INIT
    cd $_PROJECT_PATH
    rm dist -rf
    # 4.0.0.0.R19.1 - ERROR - Angular is running in the development mode. Call enableProdMode() to enable the production mode.
    # --environment=prod
    $__ng build --prod --base-href $_PROJECT_CONTEXT --aot true --environment=prod --sourcemaps false
    #    # 4.0.0.0.R19.0 - ERROR - In prod mode, navigation does not work.
    #    ng build --prod --base-href /admin/ --aot true --env=prod --sourcemaps true
    _frontName=pre-$_frontName
    compress $_frontName dist
    mv $_frontName $_dist
    _zip=pre-$_zip
    _zip=$_PROJECT_DIST$_zip
  echo FRONTENT PROD - END
}

function frontProdMap()
{
  echo FRONTEND PROD - MAP - INIT - R2.3 - getToken get undefined value
    cd $_PROJECT_PATH
    rm dist -rf
    $__ng build --prod --base-href $_PROJECT_CONTEXT --aot --optimization=true --source-map=true --vendor-chunk=true --output-hashing=all --preserve-symlinks

   _zip=$_PROJECT_DIST-prod-map-$_zip

   toDist $_zip

  echo FRONTEND PROD - MAP - END
}

function toDist()
{
  echo TO-ZIP - INIT
  echo File: $1

  cd $_PROJECT_PATH
  zip $1 dist/* -r

  echo TO-ZIP - END
}

function frontWar()
{
  echo FRONTEND PROD - WAR - INIT

    cd $_PROJECT_PATH
    rm dist -rf

    $__ng build --prod --base-href $_PROJECT_CONTEXT --aot --optimization=true --source-map=true --vendor-chunk=true --output-hashing=all

  echo FRONTEND PROD - MAP - END
}

function frontProd()
{
  echo FRONTEND PROD - INIT
    cd $_PROJECT_PATH
    rm dist -rf

    $__ng build --prod --base-href $_PROJECT_CONTEXT --aot true --environment=prod --sourcemaps false --output-hashing=all

    _frontName=prod-$_frontName
    compress $_frontName dist
    mv $_frontName $_dist
    _zip=prod-$_zip
    _zip=$_PROJECT_DIST$_zip
  echo FRONTEND PROD - END
}

function testExecuteRemote()
{

  sshpass -p .clearone! ssh jesus@portal4.spontania.net mkdir $_distName
}

function warnings()
{
  echo Warnings - INIT
    echo WARNINGS - $_zip
      echo co-config.bus.ts VERSION
      echo GIT - SPONTANIA API - Pull
    ### 07/11/2017 ###  echo GIT - SPONTANIA Rest - Pull
      echo GIT - SPONTANIA WEB - Pull
      read -t5 -n1 -r -p 'Press any key to cancel in the next five seconds...' key
      if [ "$?" -eq "0" ]; then
        exit
      fi
  echo Warnings - END
}

function apiConfigXml()
{
  echo Config.xml localhost - INIT
    configXml localhost
#    cd /root/git/SpontaniaApi/src
#    rm config.xml -f
#    cp config-localhost.xml config.xml
  echo Config.xml localhost - END
}

function configXml()
{
  echo configXml - INIT - $1
    _server=$1
    # Source
    cd /root/git/SpontaniaApi/src
    rm config.xml -f
    cp config.$_server config.xml

    # Tomcat lib
    cd /usr/local/tomcat/lib
    rm config.xml -f
    cp /root/git/SpontaniaApi/src/config.$_server config.xml

  echo configXml - END

}

function db()
{
  echo DB - INIT
    _folder=db
    _path=$_dist/$_folder
    mkdir $_path

    cd /root/git/SpontaniaApi/database/4.0
    cp * $_path/.

    cd $_dist
    compress $_dbName $_folder
  echo DB - END
}

function apiCompile()
{
  echo Compile SpontaniaApi - INIT - 201711151746
    _folder=api
    _path=$_dist/$_folder
    mkdir $_path

    apiConfigXml
    ant -buildfile /root/git/SpontaniaApi/build.xml
    cd /usr/local/tomcat/lib
    cp xmlrpcapi.jar $_path/.

    cd $_dist
    compress $_apiName $_folder

    apiDevCompile

  echo Compile SpontaniaApi - END
}

function apiDevCompile()
{
  echo apiDevCompile - INIT
    configXml portal4
    ant -buildfile /root/git/SpontaniaApi/build.xml
  echo apiDevCompile - END

}

function apiCol4Compile()
{
  echo apiDevCompile - INIT
    configXml collaborate4
    ant -buildfile /root/git/SpontaniaApi/build.xml
  echo apiDevCompile - END

}
function compress()
{
  echo Compres - INIT - $1 - $2
    _tarGz=$1
    _source=$2
    tar -czvf $_tarGz $_source -h
  echo Compres - END
}

function compressByFile()
{
  echo Compres - INIT
    _tarGz=$1
    _include=$2
    tar -czvf $_tarGz --files-from=$_PROJECT_PATH/sh/$_include -h
  echo Compres - END
}

function toVersions()
{
  echo Move to Versions - INIT
    cd $_PROJECT_PATH
    mv *.zip ./versions/.
    #    mv $1 versions/.
    cd ..
#    rm $_dist -fr
  echo Move to Versions - END
}

function distInit() {
  echo distInit - INIT
    cd $_PROJECT_PATH
    rm $_dist -fr
    mkdir $_dist
  echo distInit - END
}


function distEnd() {
  echo distEnd - INIT
    cd $_PROJECT_PATH
    rm $_dist -fr
  echo distEnd - END
}

function externalLib() {
  echo externalLib - INIT
    _folder=externalLib
    _path=$_dist/$_folder
    mkdir $_path

    echo externalLib - REST - INIT
      cd $_REST_EXTERNAL_PATH
      cp * $_path/.
    echo externalLib - REST - END

    echo externalLib - API - INIT
      cd $_API_EXTERNAL_PATH
      cp * $_path/.
    echo externalLib - API - END

    cd $_dist
    compress $_externalName $_folder

  echo externalLib - END
}

function portal4Install() {
  echo portal4Install - INIT
#    sshpass -p .clearone! ssh jesus@portal4.spontania.net mkdir $_distName
    sshpass -p .clearone! ssh jesus@portal4.spontania.net unzip $_distName
  echo portal4Install - END
}

function send() {

  echo SEND ALL - INIT - 1810151401
  echo   file: $1
    collaborate4Send $1
    collaborate4DevelopSend $1
    prodSend $1
    usSend $1
  echo .
}

function install() {
  echo INSTALL - INIT
  echo   file: $1

  tput setaf $_COLOR_GREEN
  echo -e "Install Collaborate4d? "
    read _c4d_install
    if [[ $_c4d_install = 'y' ]]
    then
        collaborate4DevelopInstall $1
    fi
  tput sgr0

  tput setaf $_COLOR_BLUE
  echo -e "Install CollaborateSpace.us? "
    read _cs_us_install
    if [[ $_cs_us_install = 'y' ]]
    then
        usInstall $1
    fi
  tput sgr0

  tput setaf $_COLOR_RED
  echo -e "Install CollaborateSpace.net? "
    read _cs_net_install
    if [[ $_cs_net_install = 'y' ]]
    then
        prodInstall $1
    fi
  tput sgr0

  echo INSTALL - END
}

# R23.2 - ERROR - Angular is running in the development mode ...
function distribute() {
  echo Distribute - INIT
  _type=$1
  echo Type: $_type

  distInit

  # Front
  if [[ $_type = 'dev' ]]
  then
    frontDev
  fi
  if [[ $_type = 'pre' ]]
  then
    frontPre
  fi

  if [[ $_type = 'map' ]]
  then
    frontProdMap
  fi


  if [[ $_type = 'prod' ]]
  then
    frontProd
  fi

  #send $_zip
#  war
  distWar

  toVersions
  distEnd

  echo distribute - END
}

function war() {
    echo WAR - INIT

    cd $_PROJECT_PATH
    ./node_modules/grunt-cli/bin/grunt

    echo WAR - END
}

function distWar() {
    echo distWar - INIT

    versionWrite

    war


    cd $_PROJECT_PATH/war
    send $_WAR
    install $_WAR

    echo distWar - END
}

#The literal project json files unify - 1810151342
function versionWrite() {

    _versionWriteFile=$_PROJECT_PATH
    _versionWriteFile+=/src/assets/version

    echo :: VERSION WRITE - INIT
    echo :: _versionWriteFile: $_versionWriteFile
    echo $_APP_NAME $_APP_VERSION >$_versionWriteFile
    echo :: VERSION WRITE - END
}


function ngxTranslateEnabled() {
    _ngxTranslateFile=$_PROJECT_PATH/src/app/cs/tool/literal.ts
    echo _ngxTranslateFile: $_ngxTranslateFile
    mv $_ngxTranslateFile.disabled $_ngxTranslateFile

}

function ngxTranslateDisabled() {
    _ngxTranslateFile=$_PROJECT_PATH/src/app/cs/tool/literal.ts
    echo _ngxTranslateFile: $_ngxTranslateFile
    mv $_ngxTranslateFile $_ngxTranslateFile.disabled
}