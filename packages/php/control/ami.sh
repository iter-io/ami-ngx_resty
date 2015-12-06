#!/bin/bash


##              ##
#  BUILD CONFIG  #
##              ##

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=php

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data
CONF_DIR=/etc/opt/${PACKAGE_NAME}
LOG_DIR=/var/opt/log/${PACKAGE_NAME}
RUN_DIR=/var/opt/run


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

if [ ! -d ${RUN_DIR}/php-fpm ]; then
    mkdir -p ${RUN_DIR}/php-fpm
fi


##                      ##
#  INSTALL DEPENDENCIES  #
##                      ##

# For Debian
# apt-get install php5 php5-fpm php5-pgsql

# For Amazon Linux
yum install -y php.x86_64 php-devel.x86_64 php-fpm.x86_64 php-pdo.x86_64 php-mysql.x86_64


##                  ##
#  COMPILE PHPREDIS  #
##                  ##

# Create the package directory with most recent source
if [ -d ${PACKAGE_DIR}/phpredis ]; then
  cd ${PACKAGE_DIR}
  git pull
else
  git clone                   \
    --branch master           \
    --single-branch           \
    --depth 1                 \
    https://github.com/phpredis/phpredis.git ${PACKAGE_DIR}/phpredis
fi

cd ${PACKAGE_DIR}/phpredis
phpize
./configure

make V=1 > ${LOG_DIR}/phpredis_make.log 2>&1
error_check $? $((LINENO-1)) 'phpredis make failed'

make install > ${LOG_DIR}/phpredis_make_install.log 2>&1
error_check $? $((LINENO-1)) 'phpredis make install failed'


##                ##
#  INSTALL CONFIG  #
##                ##

install --owner=root --group=root --mode=644 ${DATA_DIR}/dev-php.ini /etc/php.ini

# Install config for PHP-FPM pool
install --owner=root --group=root --mode=644 ${DATA_DIR}/php-fpm.d/www.conf /etc/php-fpm.d/www.conf

##                     ##
#  CREATE PHP-FPM USER  #
##                     ##

useradd --user-group --shell /bin/false --system --no-create-home php-fpm

# Start PHP-FPM
/etc/init.d/php-fpm start

# Signal SUCCESS
exit 0
