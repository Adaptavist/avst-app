#!/bin/bash
# Insipired by:
#   https://stash.adaptavist.com/projects/ATB/repos/fpm-builder/browse/build-crowd.sh
#   https://bitbucket.org/Adaptavist/fpm-puppet

# Pull in any RVM variables for Ruby to work
[ -r /etc/profile.d/rvm.sh ] && . /etc/profile.d/rvm.sh

# Exit on error
#set -e

# Treat using unset variables as an error
#set -u

cd $( dirname $0 )

for bin in fpm git ; do
  if ! type ${bin} >/dev/null ; then
  	echo
  	echo "${bin} command not found please install" >&2
  	echo
  	exit 10
  fi
done

INSTALL_PREFIX="/usr/"
ITERATION=$( git rev-parse --short HEAD )

function usage () {
  echo "$( basename $0 )  --version <version> [--install-prefix] [--iteration]"
  echo ""
  echo "These parameters get passed directly to fpm in order to build the packages."
  echo "See fpm help for information on these parameters."
}

# Basic option handling
while (( $# > 0 ))
do
  opt="$1"

  case $opt in
    --help)
        usage
        exit 0
        ;;
    --version)
        VERSION="$2"
        shift
        ;;
    --install-prefix)
        INSTALL_PREFIX="$2"
        shift
        ;;
    --iteration)
        ITERATION="$2"
        shift
        ;;
    --*)
        echo "Invalid option: '$opt'"
        usage
        exit 1
        ;;
    *)
       # end of long options
       break
       ;;
  esac
  shift # do this after the case statements, so the first param is not lost!
done

if [[ -z "${VERSION:-}" ]]; then
    echo "Invalid usage: version must be provided"
    usage
    exit 10
fi

function build-package () {
  # TODO: Check dependancies for: Augeas (augeas-tools), bsdtar on CentOS
  local PKG_NAME=$1
  local DIRS=$2
  local DEPS=$3
  local DESC=$4

  for pkg in rpm deb; do
    if [[ ${pkg} == deb ]]; then
      ADDITIONAL_DEPS="-d augeas-tools -d dos2unix"
    else
      ADDITIONAL_DEPS="-d augeas -d dos2unix"
    fi
    fpm \
      -s dir \
      -t ${pkg} \
      -n ${PKG_NAME} \
      --prefix ${INSTALL_PREFIX} \
      --version ${VERSION} \
      --iteration ${ITERATION} \
      --license "Commercial" \
      --vendor "Adaptavist" \
      -a "all" \
      --url "http://www.adaptavist.com/" \
      --description "${DESC}" \
      -m "managed-services@adaptavist.com" \
      -d "tar" \
      ${DEPS} \
      ${ADDITIONAL_DEPS} \
      $( echo ${DIRS} )
  done
}

build-package avst-app \
              "bin share/avst-app/doc share/avst-app/upstart share/avst-app/lib/common share/avst-app/systemd" \
              "" \
              "Adaptavist application management scripts - Common"

build-package avst-app-crowd \
              "share/avst-app/lib/product/crowd" \
              "-d avst-app -d avst-app-atlassian -d avst-app-tomcat" \
              "Adaptavist application management scripts - Crowd"

build-package avst-app-bitbucket \
              "share/avst-app/lib/product/bitbucket" \
              "-d avst-app -d avst-app-atlassian -d avst-app-tomcat" \
              "Adaptavist application management scripts - Bitbucket"

build-package avst-app-bamboo \
              "share/avst-app/lib/product/bamboo" \
              "-d avst-app -d avst-app-atlassian -d avst-app-tomcat" \
              "Adaptavist application management scripts - Bamboo"

build-package avst-app-bamboo-agent \
              "share/avst-app/lib/product/bamboo_agent" \
              "-d avst-app" \
              "Adaptavist application management scripts - Bamboo Agent"

build-package avst-app-fisheye \
              "share/avst-app/lib/product/fisheye" \
              "-d avst-app" \
              "Adaptavist application management scripts - Fisheye"

build-package avst-app-jira \
              "share/avst-app/lib/product/jira" \
              "-d avst-app -d avst-app-atlassian -d avst-app-tomcat" \
              "Adaptavist application management scripts - JIRA"

build-package avst-app-artifactory \
              "share/avst-app/lib/product/artifactory" \
              "-d avst-app -d avst-app-tomcat" \
              "Adaptavist application management scripts - Artifactory"

build-package avst-app-tomcat \
              "share/avst-app/lib/tomcat" \
              "-d avst-app" \
              "Adaptavist application management scripts - Tomcat"

build-package avst-app-atlassian \
              "share/avst-app/lib/atlassian" \
              "-d avst-app -d avst-app-tomcat" \
              "Adaptavist application management scripts - Atlassian"
              
build-package avst-app-coverity \
              "share/avst-app/lib/product/coverity" \
              "-d avst-app -d avst-app-tomcat" \
              "Adaptavist application management scripts - Coverity"

build-package avst-app-confluence \
              "share/avst-app/lib/product/confluence" \
              "-d avst-app -d avst-app-atlassian -d avst-app-tomcat" \
              "Adaptavist application management scripts - Confluence"

build-package avst-app-sonarqube \
              "share/avst-app/lib/product/sonarqube" \
              "-d avst-app" \
              "Adaptavist application management scripts - SonarQube"

build-package avst-app-synchrony \
              "share/avst-app/lib/product/synchrony share/avst-app/scripts/synchrony" \
              "-d avst-app" \
              "Adaptavist application management scripts - Synchrony"

exit 0

