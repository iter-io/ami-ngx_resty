#!/bin/bash

##              ##
#  BUILD CONFIG  #
##              ##

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=security

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data

# Copy security config files to /etc/security
cp -prv ${DATA_DIR}/etc/security/limits.conf /etc/security/limits.conf


# Signal SUCCESS
exit 0
