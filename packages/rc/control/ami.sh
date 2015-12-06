#!/bin/bash

##              ##
#  BUILD CONFIG  #
##              ##

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=sysctl

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data

##                    ##
#  INSTALL RC SCRIPTS  #
##                    ##

install --group=root --mode=755 --owner=root ${DATA_DIR}/rc.local /etc/rc.d/

install --group=root --mode=755 --owner=root ${DATA_DIR}/delayedshutdown /etc/rc.d/init.d/

ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc0.d/K01delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc1.d/S99delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc2.d/S99delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc3.d/S99delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc4.d/S99delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc5.d/S99delayedshutdown
ln -s /etc/rc.d/init.d/delayedshutdown /etc/rc.d/rc6.d/K01delayedshutdown


# Signal SUCCESS
exit 0
