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


install --group=root --mode=644 --owner=root ${DATA_DIR}/sysctl.conf /etc/


# Signal SUCCESS
exit 0
