#!/bin/bash
source /etc/profile.d/env_variables.sh

NUTCRACKER_DEBUG=$1
MAINTAINER='Rhommel Lamas <roml@rhommell.com> @rhoml'
DESCRIPTION='A fast, light-weight proxy for memcached and redis.'
NUTCRACKER_URL='https://github.com/twitter/twemproxy'
PACKAGE_TYPE=$package
NAME=nutcracker
BUILD_DIR=/tmp/twemproxy

do_install_debian_dependencies() {
  # Installs needed package dependencies
  apt-get update
  apt-get upgrade -y
  apt-get install -y build-essential
  apt-get install -y git
  apt-get install -y ruby1.9.1
  apt-get install -y ruby1.9.1-dev
  apt-get install -y libtool
  apt-get install -y autoconf

  # Installs FPM
  /usr/bin/gem1.9.1 install fpm

  # Installs package_cloud gem
  /usr/bin/gem1.9.1 install package_cloud
}

do_create_directories() {
  mkdir -p /tmp/twemproxy/opt/nutcracker/{sbin,log,etc}
  mkdir -p /tmp/twemproxy/etc/init.d
}

do_install_redhat_dependencies() {
 echo "Redhat"
}

do_retrieve_twemproxy_code() {
  cd /usr/src
  git clone https://github.com/twitter/twemproxy.git
}

do_build_twemproxy() {
  cd /usr/src/twemproxy
  autoreconf -fvi
  sh configure
  make && make install
}

do_prepare_fpm() {
  cp /usr/local/sbin/nutcracker /tmp/twemproxy/opt/nutcracker/sbin/nutcracker
  # Will enable nutcracker init from next version.
  #cp /usr/src/twemproxy/scripts/nutcracker.init.debian /tmp/twemproxy/etc/init.d/nutcracker
  cp /usr/src/twemproxy/conf/nutcracker.yml /tmp/twemproxy/opt/nutcracker/etc/nutcracker.yml.example
}

do_build_fpm_package() {
  local package_type=$1
  local package_name=$NAME

  echo $BUILD_DIR
  echo $package_type
  echo $NUTCRACKER_VERSION
  echo $MAINTAINER
  echo $NUTCRACKER_URL
  echo $DESCRIPTION
  
  fpm -s dir -t ${package_type} -C $BUILD_DIR --name ${package_name} --version ${NUTCRACKER_VERSION} --iteration 1 --maintainer "${MAINTAINER}" --url ${NUTCRACKER_URL} --description "${DESCRIPTION}" .
}

do_push_package_cloud() {
  local package_name=$1
  
  echo "{\"https://packagecloud.io\":\"https://packagecloud.io\",\"token\":\"${pc_token}\"}" >> /root/.packagecloud
  package_cloud push ${pc_username}/twemproxy/any/any /usr/src/twemproxy/${package_name}
}

main() {
  if [ $distribution == 'ubuntu' ]; then
    do_install_debian_dependencies
    do_create_directories
    do_retrieve_twemproxy_code
    cd /usr/src/twemproxy
    NUTCRACKER_VERSION=`git tag --list | tail -1 | sed 's/v//'`
    git checkout v$NUTCRACKER_VERSION
    do_build_twemproxy
    do_prepare_fpm
    do_build_fpm_package deb
    do_push_package_cloud nutcracker_${NUTCRACKER_VERSION}-1_${architecture}.deb
  else
    do_install_redhat_dependencies
    do_create_directories
    do_retrieve_twemproxy_code
    cd /usr/src/twemproxy
    NUTCRACKER_VERSION=`git tag --list | tail -1 | sed 's/v//'`
    git checkout v$NUTCRACKER_VERSION
    do_build_twemproxy
    do_prepare_fpm
    do_build_fpm_package rpm
  fi
}

main
