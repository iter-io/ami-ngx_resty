#!/bin/bash

PROVIDER_NAME=iterio
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


##                  ##
#  HELPER FUNCTIONS  #
##                  ##

function error_check()
{
  THIS_FILE_NAME=${0}
  EXIT_STATUS=${1}
  LINE=${2}
  MESSAGE=${3:-"Unknown Error"}

  if [ ${EXIT_STATUS} -ne 0 ]; then
    echo "ERROR ($THIS_FILE_NAME: line $LINE): $MESSAGE"
    exit 1
  fi
}

# Setup /opt for the packages
mkdir /opt/{bin,sbin,${PROVIDER_NAME}}

PACKAGES=$(cat ${SCRIPT_DIR}/go-sequence.txt | xargs)

# Install packages by executing each control script
for PACKAGE in ${PACKAGES}; do

  PACKAGE_NAME=$(basename ${PACKAGE})
  echo "Installing "${PACKAGE_NAME}"..."

  bash ${SCRIPT_DIR}/packages/${PACKAGE}/control/ami.sh
  error_check $? $((LINENO-1)) ${PACKAGE_NAME}" installation failed"
done

exit 0