#! /bin/bash
# Patch_create-9.1.20160310
_subversion=$(date +%Y%m%d)
clear
################################################################################ 
#
#
#
#
################################################################################
# Param ######################################################################## 
_web_version=$1
_version=$_web_version.$_subversion
_server_version=$2
_gateway_version=$3    # 13.0.20160412
if [[ $1 = '' || $2 = '' || $3 = '' ]] 
then
	echo -e "Faltan parametros"
	echo -e "Example: ./patch_create.sh 3.1 6.8.2.9 3.2.0.7"
	exit
fi 
################################################################################ 
#
#
#
#
################################################################################ 
# Config ####################################################################### 
_spontania=/usr/local/Spontania
_patch_path=$_spontania/patch.$_version
_patch_sql=$_patch_path/patch.$_version.sql
_patch_utils=$_spontania/patch-utils
_download_path=/usr/local/tomcat/webapps/comun/download
_sql=$_spontania/SpontaniaSql
_sql_modules=$_sql/modules
_sql_updaters=$_sql/updaters
_bin=/usr/local/bin
_server=webconferencebase.$_server_version
_server_lib=libserver.$_server_version.tar.gz
_log=$_patch_path/create.log
################################################################################ 
#
#
#
#
################################################################################
# Create sh #################################################################### 
echo -e "Version: $_version"
mkdir $_patch_path
_sh=$_patch_path/patch.$_version.sh
_before=$_patch_utils/patch.before.sh
_after=$_patch_utils/patch.after.sh
cat $_before > $_sh
echo -e "_version=$_version" >> $_sh
echo -e "_version_server=$_server_version" >> $_sh
cat $_after >> $_sh
################################################################################ 
#
#
#
#
################################################################################
# Copy include and exclude ##################################################### 
cp /$_patch_utils/patch.files_include /$_patch_path/patch.$_version.files_include
cp /$_patch_utils/patch.files_exclude /$_patch_path/patch.$_version.files_exclude
cp /$_patch_utils/patch.files_include /$_patch_path/patch.$_version.files_create		
################################################################################ 
#
#
#
#
################################################################################
# Server 8.0.20160226 ########################################################## 
echo -e "Server"
# config
### cp /$_patch_utils/webconference-config.xml /$_patch_path/webconference-config.xml
# lib
cp /usr/local/Spontania/server/$_server_lib /$_patch_path/libserver.tar.gz
# server
cp /usr/local/Spontania/server/$_server /$_patch_path/$_server
echo -e "/Server"
################################################################################ 
#
#
#
#
################################################################################
# Gateway 13.0.20160412 ######################################################## 
echo -e "Gateway"
# gateway
### cp /$_patch_utils/webconference-config.xml /$_patch_path/webconference-config.xml
_gateway_path=/home/jesus/versions/VAS/Gateways/H323_SIP_v3/Version_$_gateway_version
cp /$_gateway_path/RPMS/WebConferenceGateway* /$_patch_path/
# videos
cp /$_gateway_path/Videos/GW_Videos_720p.tgz /$_patch_path/GW_Videos_720p.tgz
echo -e "/Gateway"
################################################################################ 
#
#
#
#
################################################################################
# join modules 5.0.20160223 ####################################################
echo -e "join modules $_sql_modules"
## Unactive NOTICES in postgresql
echo -e "SET client_min_messages TO WARNING;" > $_patch_sql

cd $_sql_modules
_modules=`find * -name "*.sql"`
for _module in $_modules ;
do
    echo -e ""                         >> $_patch_sql
	echo -e "-- Module - $_module "    >> $_patch_sql        
	cat $_module >> $_patch_sql
	echo -e "--/Module - $_module "    >> $_patch_sql        
	echo -e ""                         >> $_patch_sql
done

echo -e "/join modules"
################################################################################
#
#
#
#
################################################################################ 
# Updaters Sql - 6.0.20160224 ##################################################
echo -e "Updaters Sql $_sql_updaters"
cd $_sql_updaters
_updaters=`find * -name "*.sql"`
for _updater in $_updaters ;
do
	echo -e ""                          >> $_patch_sql
	echo -e "-- Update - $_updater "    >> $_patch_sql        
    cat $_updater                       >> $_patch_sql
	echo -e "--/Update - $_updater "    >> $_patch_sql        
	echo -e ""                          >> $_patch_sql
done
echo -e "/Updaters Sql"
################################################################################
#
#
#
#
################################################################################ 
# WebServices 10.0.20160316 #################################################### 
mkdir /$_patch_path/ws
## General ##################################################################### 
_WebService=General
mkdir /$_patch_path/ws/$_WebService
cd /root/git/WebServices$_WebService/src/com/dialcom/ws/services
cp *.wsdd /$_patch_path/ws/$_WebService
## InfoSession ################################################################# 
_WebService=InfoSession
mkdir /$_patch_path/ws/$_WebService
cd /root/git/WebServices$_WebService/src/com/dialcom/services/soap
cp *.wsdd /$_patch_path/ws/$_WebService
## Package ###################################################################### 
_WebService=Package
mkdir /$_patch_path/ws/$_WebService
cd /root/git/WebServices$_WebService/src/com/spontania/spackage/services
cp *.wsdd /$_patch_path/ws/$_WebService
## User ######################################################################## 
_WebService=User
mkdir /$_patch_path/ws/$_WebService
cd /root/git/WebServices$_WebService/src/com/spontania/user/services
cp *.wsdd /$_patch_path/ws/$_WebService
################################################################################ 
#
#
#
#
################################################################################
# Batch 11.0.20160321 ########################################################## 
echo -e "Version web: " $_web_version
if [[ $_web_version = '3.1' ]] 
then
	echo -e "Not install SpontaniaConsole"
fi
if [[ $_web_version = '3.2' ]] 
then
	echo -e "Install SpontaniaConsole"
	cd /root/git/SpontaniaConsole
	ant
fi
################################################################################ 
#
#
#
#
################################################################################
# Manage Entity Expiration 11.0.20160321 #######################################
_mee_path=/usr/local/tomcat/webapps/webconference/partners/1/mails/template
cd $_mee_path
zip $_patch_path/notice.zip notice*.jsp
################################################################################ 
#
#
#
#
################################################################################
# Add Clients 12.0.20160330 #################################################### 
_clients_path=/usr/local/Spontania/clients
cd $_clients_path
zip $_patch_path/clients.zip *
################################################################################ 
#
#
#
#
################################################################################
# Normalize files (UTF-8, properties, owner) ################################### 
cd /$_patch_path
pwd
dos2unix *.files_include
dos2unix *.notes
dos2unix *.sh
dos2unix *.sql
dos2unix *.wsdd


chown root:root *
chmod 0755 *.sh
################################################################################ 
#
#
#
#
################################################################################
# Add extra files ############################################################## 
echo -e $_patch_path >>patch.$_version.files_create
echo -e $_patch_path/patch.$_version.tar.gz >>patch.$_version.files_exclude
################################################################################ 
#
#
#
#
################################################################################
cd /
tar -czvf $_patch_path/patch.$_version.tar.gz  --files-from=$_patch_path/patch.$_version.files_create -h --exclude-from=$_patch_path/patch.$_version.files_exclude >>$_log
################################################################################ 
#
#
#
#
################################################################################
# Create zip
cd /$_patch_path
zip patch.$_version.zip patch.$_version.{sh,files_include,files_exclude,tar.gz}
################################################################################ 
#
#
#
#
################################################################################
# Copy 253 - 5.0 ############################################################### 
echo -e "Copy to 253/current_releases/TESTING/patch"
cd $_patch_path
cp patch.$_version.zip /home/jesus/current_releases/TESTING/patch
echo -e "/Copy to 253"
################################################################################ 
#
#
#
#
################################################################################
# Copy Testv3 - 5.0 ############################################################ 
cd $_patch_path
echo -e "Copy to iso$_web_version"
sshpass -p .clearone14! scp patch.$_version.zip root@iso$_web_version:/
echo -e "/Copy to iso$_web_version"
echo -e "Copy to TESTV3"
sshpass -p clearone! scp patch.$_version.zip jesus@testv3.spontania.com:/home/jesus
echo -e "/Copy to TESTV3"
################################################################################ 
#
#
#
#
################################################################################

#END
################################################################################ 
#
#
#
#
################################################################################
# Release Notes ################################################################ 
################################################################################ 
# 13.0.20160412 ################################################################ 
#   Add param Gateway ($3)
################################################################################ 
# 12.0.20160330 ################################################################ 
#   Add Clients
################################################################################ 
# 11.0.20160321 ################################################################ 
#   Add Batch
#   Add module "Manage Entity Expiration"
################################################################################ 
# 10.0.20160316 ################################################################ 
#   Add WebServices
################################################################################ 
# 9.1.20160310 ################################################################# 
#   Add break line en sql
#   Add Eliminate Notices in postgresql
################################################################################ 
# 9.0.20160301 ################################################################# 
#   Add Gateway
#   Add date version
################################################################################ 
# 8.0.20160226 ################################################################# 
#   Add Server
################################################################################ 
# 7.0.20160225 ################################################################# 
#   Add Param
#   Add Create sh 
################################################################################ 
# 6.0.20160224 ################################################################# 
#   Add Updaters Sql
################################################################################ 
# 5.0.20160223 ################################################################# 
#   Add join modules
#   Add Copy Testv3
#   Add Copy 253
################################################################################ 
# 4.0.20160204 ################################################################# 
#   Add patch.files_create
#   Add extra files
#   Add create zip
################################################################################ 
# 3.1.20160120 ################################################################# 
#   Add _patch_utils path de include and exclude files
#   Add copy include and exclude files
# 	Fix bug path include and exclude
################################################################################
# 3.0.20160118 ################################################################# 
# 	Add exclude files in file "*.files_exclude"
# 	Add all context in tar.gz
################################################################################
# 2.2 20151113 ################################################################# 
#   To specify files in dos2unix
################################################################################ 
# 2.1 ########################################################################## 
# 	Convert to unix 
#	Add properties
################################################################################ 
# 2.0 new path patch
