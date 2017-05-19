#!/bin/bash

# Exit on error
set -e

# Treat using unset variables as an error
set -u

function usage () {
  echo "$( basename $0 )  [--snapshot] --version <version> [--file <file>|--all-files]"
  echo "      [--bintray-user --bintray-password --bintray-url --bintray-deb-repo --bintray-rpm-repo --bintray-deb-options --bintray-rpm-options]"
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
    --snapshot)
        SNAPSHOT="-snapshots"
        ;;
    --version)
        VERSION="$2"
        shift
        ;;
    --bintray-user)
        BIN_USER=$2
        shift
        ;;
    --bintray-password)
        BIN_PASS=$2
        shift
        ;;
    --bintray-url)
        BIN_URL=$2
        shift
        ;;
    --bintray-deb-repo)
        BIN_DEB_REPO=$2
        shift
        ;;
    --bintray-rpm-repo)
        BIN_RPM_REPO=$2
        shift
        ;;
    --bintray-deb-options)
        BIN_DEB_OPTIONS=$2
        shift
        ;;
    --bintray-rpm-options)
        BIN_RPM_OPTIONS=$2
        shift
        ;;
    --deb-file)
        if [[ ! -z ${FILELIST_DEB:-} ]]; then
          echo "Error: --deb-file and --all-files or --all-debs are mutually exclusive"
          usage
          exit 4
        fi
        FILELIST_DEB="$2"
        shift
        ;;
    --rpm-file)
        if [[ ! -z ${FILELIST_RPM:-} ]]; then
          echo "Error: --rpm-file and --all-files or --all-rpms are mutually exclusive"
          usage
          exit 4
        fi
        FILELIST_RPM="$2"
        shift
        ;;
    --all-files)
        if [[ (! -z ${FILELIST_DEB:-} || 
          ! -z ${FILELIST_RPM:-}) ]]; then
          echo "Error: --all-files and --file, --all-debs or --all-rpms are mutually exclusive"
          usage
          exit 4
        fi
        FILELIST_DEB=$( echo *.deb )
        FILELIST_RPM=$( echo *.rpm )
        ;;
    --all-debs)
        if [[ ! -z ${FILELIST_DEB:-} ]]; then
          echo "Error: --all-debs and --deb-file or --all-files are mutually exclusive"
          usage
          exit 4
        fi
        FILELIST_DEB=$( echo *.deb )
        ;;
    --all-rpms)
        if [[ ! -z ${FILELIST_RPM:-} ]]; then
          echo "Error: --all-rpms and --rpm-file or --all-files are mutually exclusive"
          usage
          exit 4
        fi
        FILELIST_RPM=$( echo *.rpm )
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

if [[ ( ! -z "${FILELIST_DEB:-}" || ! -z "${FILELIST_RPM:-}" ) && ! -z "${VERSION:-}" ]]; then
    
  # Variables (I'd say global - but they're all like that in shell)
  # TODO: Make these variables able to be passed in as options
  MVN_URL=${MVN_URL:-"https://nexus.adaptavist.com/content/repositories/"}
  MVN_REPOID=${MVN_REPOID:-"nexus"}
  MVN_GROUPID=${MVN_GROUPID:-"com.adaptavist.mama.avst-app"}
  MVN_REPO=${MVN_REPO:-"adaptavist"}
  if [[ ! -z "${SNAPSHOT:-}" ]]; then
    MVN_REPO="adaptavist${SNAPSHOT:-}"
    VERSION="${VERSION}-SNAPSHOT"
  fi

  # default the bintray variables if they have not been passed in as args
  BIN_URL=${BIN_URL:-"https://api.bintray.com/content/adaptavist"}
  BIN_DEB_REPO=${BIN_DEB_REPO:-"ubuntu"}
  BIN_RPM_REPO=${BIN_RPM_REPO:-"rpm"}
  BIN_DEB_OPTIONS=${BIN_DEB_OPTIONS:-";publish=1;deb_component=main;deb_distribution=ubuntu;deb_architecture=i386,amd64"}
  BIN_RPM_OPTIONS=${BIN_RPM_OPTIONS:-"?publish=1"}

  echo "Publishing \"${FILELIST_DEB}\" artefacts"
  for FILE in ${FILELIST_DEB}; do
    #TODO: Only does .debs for now
    echo "Publishing \"${FILE}\" to Nexus"
    MVN_DESC=$( dpkg --info ${FILE} | fgrep Description | sed -e's/[^:]*: //' )
    MVN_ARTIFACT=$( echo ${FILE} | sed -e's/_.*//' )
    CMD="mvn org.apache.maven.plugins:maven-deploy-plugin:2.8.1:deploy-file \
                         -Durl=${MVN_URL}/${MVN_REPO} \
                         -DrepositoryId=${MVN_REPOID} \
                         -Dfile=${FILE} \
                         -DgroupId=${MVN_GROUPID} \
                         -DartifactId=${MVN_ARTIFACT} \
                         -Dversion=${VERSION} \
                         -Dclassifier=all \
                         -Dpackaging=deb \
                         -DgeneratePom=true \
                         -DgeneratePom.description=\"${MVN_DESC}\""
    echo "Running: >>>>${CMD}<<<<<"
    eval ${CMD}

    # ** BINTRAY release **
    # TODO: currently uploading a file for a package that does not exist on bintray will fail, add code to create if not present
    # run bintray release if this is not a snapshot build
    if [[ -z "${SNAPSHOT:-}" ]]; then
      # if we have not got a bintray user/pass do not attempt the upload
      if [[ ! -z ${BIN_USER:-} && ! -z ${BIN_PASS:-} ]]; then
        echo "Publishing \"${FILE}\" to Bintray"
        BINTRAY_PACKAGE=$( echo ${FILE} | sed -e's/_.*//' )
        BIN_CMD="curl -T ${FILE} -u${BIN_USER}:${BIN_PASS} '${BIN_URL}/${BIN_DEB_REPO}/${BINTRAY_PACKAGE}/${VERSION}/${FILE}${BIN_DEB_OPTIONS}'"
        echo "Running: >>>>${BIN_CMD}<<<<<"
        eval $BIN_CMD
      else
        echo "SKipping publishing \"${FILE}\" to Bintray, as there are no auth details!"
      fi
    fi
    
  done

  echo "Publishing \"${FILELIST_RPM}\" artefacts"
  for FILE in ${FILELIST_RPM}; do
    echo "Publishing \"${FILE}\" to Nexus"
    MVN_DESC=$( rpm -q -i -p ${FILE} | fgrep Summary | sed -e's/[^:]*: //' )
    MVN_ARTIFACT=$( echo ${FILE} | sed -e's/_.*//' )
    CMD="mvn org.apache.maven.plugins:maven-deploy-plugin:2.8.1:deploy-file \
                         -Durl=${MVN_URL}/${MVN_REPO} \
                         -DrepositoryId=${MVN_REPOID} \
                         -Dfile=${FILE} \
                         -DgroupId=${MVN_GROUPID} \
                         -DartifactId=${MVN_ARTIFACT} \
                         -Dversion=${VERSION} \
                         -Dclassifier=all \
                         -Dpackaging=rpm \
                         -DgeneratePom=true \
                         -DgeneratePom.description=\"${MVN_DESC}\""
    echo "Running: >>>>${CMD}<<<<<"
    eval ${CMD}

    # ** BINTRAY release **
    # TODO: currently uploading a file for a package that does not exist on bintray will fail, add code to create if not present
    # run bintray release if this is not a snapshot build
    if [[ -z "${SNAPSHOT:-}" ]]; then
      # if we have not got a bintray user/pass do not attempt the upload
      if [[ ! -z ${BIN_USER:-} && ! -z ${BIN_PASS:-} ]]; then
        echo "Publishing \"${FILE}\" to Bintray"
        BINTRAY_PACKAGE=$( echo ${FILE} | sed -e's/-[0-9].*//' )
        BIN_CMD="curl -T ${FILE} -u${BIN_USER}:${BIN_PASS} '${BIN_URL}/${BIN_RPM_REPO}/${BINTRAY_PACKAGE}/${VERSION}/${FILE}${BIN_RPM_OPTIONS}'"
        echo "Running: >>>>${BIN_CMD}<<<<<"
        eval $BIN_CMD
      else
        echo "SKipping publishing \"${FILE}\" to Bintray, as there are no auth details!"
      fi
    fi

  done
  exit 0
else
  echo "Invalid usage: filename and version must be provided"
  usage
  exit 10
fi
