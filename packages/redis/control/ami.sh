#!/bin/bash


##              ##
#  BUILD CONFIG  #
##              ##

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=redis

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data
CONF_DIR=/etc/opt/${PACKAGE_NAME}
LOG_DIR=/var/opt/log/${PACKAGE_NAME}
RUN_DIR=/var/opt/run

# Package specific
REDIS_VERSION=3.0

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

# Begin script execution in the control directory
cd ${CONTROL_DIR}

# Setup directories
if [ ! -d ${CONF_DIR} ]; then
    mkdir -p ${CONF_DIR}
fi

if [ ! -d ${LOG_DIR} ]; then
    mkdir -p ${LOG_DIR}
fi

if [ ! -d ${RUN_DIR} ]; then
    mkdir -p ${RUN_DIR}
fi

yum install -y gcc.noarch tcl.x86_64


##                  ##
#  CLONE/PULL REDIS  #
##                  ##

# Create the package directory
if [ -d ${PACKAGE_DIR} ]; then
  cd ${PACKAGE_DIR}
  git pull
else
  git clone                   \
    --branch ${REDIS_VERSION} \
    --single-branch           \
    --depth 1                 \
    https://github.com/antirez/redis.git ${PACKAGE_DIR}
    cd ${PACKAGE_DIR}
fi


##               ##
#  COMPILE REDIS  #
##               ##

make V=1 > ${LOG_DIR}/make.log 2>&1
error_check $? $((LINENO-1)) 'Redis make failed'

make PREFIX=${PACKAGE_DIR} install > ${LOG_DIR}/make_install.log 2>&1
error_check $? $((LINENO-1)) 'Redis make install failed'

make test > ${LOG_DIR}/make_test.log 2>&1
error_check $? $((LINENO-1)) 'Redis make test failed'


##                                 ##
#  INSTALL AND SYMLINK EXECUTABLES  #
##                                 ##


# sbin
if [ -d ${PACKAGE_DIR}/sbin ]; then
	cp -prv ${DATA_DIR}/sbin ${PACKAGE_DIR}/
fi

if [ -d ${PACKAGE_DIR}/sbin ]; then
	for FILE in ${PACKAGE_DIR}/sbin/*; do
		ln --force -s $FILE /opt/sbin/$(basename $FILE)
	done
fi


##                     ##
#  INSTALL CONFIG FILE  #
##                     ##

install ${DATA_DIR}/conf/redis.conf ${CONF_DIR}


##             ##
#  START REDIS  #
##             ##


# Install the init script
install --group=root --mode=755 --owner=root ${DATA_DIR}/amazon_linux/init.d /etc/rc.d/init.d/${PACKAGE_NAME}

/etc/init.d/${PACKAGE_NAME} start


# Signal SUCCESS
exit 0
