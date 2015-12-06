#!/bin/bash

##              ##
#  BUILD CONFIG  #
##              ##

# Common
PROVIDER_NAME=iterio
PACKAGE_NAME=ngx_resty

PROVIDER_DIR=/opt/${PROVIDER_NAME}
PACKAGE_DIR=${PROVIDER_DIR}/${PACKAGE_NAME}
CONTROL_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR=${CONTROL_DIR}/../data
CONF_DIR=/etc/opt/${PACKAGE_NAME}
LOG_DIR=/var/opt/log/${PACKAGE_NAME}
RUN_DIR=/var/opt/run

# Package specific
NGINX_USER=nginx
NGINX_GROUP=nginx
NGINX_VERSION=1.9.3.1


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


##                      ##
#  INSTALL DEPENDENCIES  #
##                      ##

yum install -y gcc.noarch GeoIP.x86_64 GeoIP-devel.x86_64 make.x86_64 \
               openssl-devel.x86_64 pcre-devel.x86_64 readline-devel.x86_64 \
               zlib-devel.x86_64

cd ${DATA_DIR}


##                   ##
#  CREATE NGINX USER  #
##                   ##

useradd --user-group --shell /bin/false --system --no-create-home nginx


##                   ##
#  SETUP DIRECTORIES  #
##                   ##

if [ ! -d ${CONF_DIR} ]; then
    mkdir -p ${CONF_DIR}
    chown nginx:nginx ${CONF_DIR}
fi

if [ ! -d ${LOG_DIR} ]; then
    mkdir -p ${LOG_DIR}
    chown nginx:nginx ${LOG_DIR}
fi

if [ ! -d ${RUN_DIR} ]; then
    mkdir -p ${RUN_DIR}
    chown nginx:nginx ${RUN_DIR}
fi


##               ##
#  COMPILE NGINX  #
##               ##

cd ${DATA_DIR}
wget https://openresty.org/download/ngx_openresty-${NGINX_VERSION}.tar.gz
tar xzvf ngx_openresty-${NGINX_VERSION}.tar.gz
cd ngx_openresty-${NGINX_VERSION}

./configure \
    --prefix=${PACKAGE_DIR} \
    --conf-path=${CONF_DIR}/nginx.conf \
    --pid-path=${RUN_DIR}/nginx.pid \
    --error-log-path=${LOG_DIR}/primary.error \
    --http-log-path=${LOG_DIR}/primary.access \
    --user=nginx \
    --group=nginx \
    --with-http_geoip_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module

make > ${LOG_DIR}/make.log 2>&1
error_check $? $((LINENO-1)) 'Nginx make failed'

make install > ${LOG_DIR}/make-install.log 2>&1
error_check $? $((LINENO-1)) 'Nginx make install failed'


##                       ##
#  INSTALL CONFIGURATION  #
##                       ##

# Deploy the nginx configuration files
cp -prv ${DATA_DIR}/conf/* ${CONF_DIR}/

# Put copies in /opt/provider/package
cp -prv ${DATA_DIR}/conf ${PACKAGE_DIR}/

# Enable the sites
mkdir ${CONF_DIR}/sites-enabled

for FILE in ${CONF_DIR}/sites-available/*; do
	ln -s $FILE ${CONF_DIR}/sites-enabled/$(basename $FILE)
done


##                                 ##
#  INSTALL AND SYMLINK EXECUTABLES  #
##                                 ##

ln -s ${PACKAGE_DIR}/nginx/sbin/nginx /opt/sbin/nginx

# Put copies in /opt/provider/package
cp -prv ${DATA_DIR}/amazon_linux ${PACKAGE_DIR}/


##             ##
#  START NGINX  #
##             ##

# configtest
${PACKAGE_DIR}/nginx/sbin/nginx -t 2>&1 | grep successful > /dev/null
error_check $? $((LINENO-1)) 'Nginx config failed test'

# Install the init script
install --group=root --mode=755 --owner=root ${DATA_DIR}/amazon_linux/init.d /etc/rc.d/init.d/nginx

/etc/init.d/nginx start


# Signal SUCCESS
exit 0
