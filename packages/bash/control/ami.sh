#!/bin/bash

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=bash

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data


##                  ##
#  Install dotfiles  #
##                  ##
cp -prv ${DATA_DIR}/etc/* /etc/


# Signal SUCCESS
exit 0
