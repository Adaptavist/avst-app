#!/bin/bash
# Copyright 2015 Adaptavist.com Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Helper Functions
# Check if we have interactive terminal, if not colors will not work
if [ "`tty`" != "not a tty" ]; then
    COL_GREEN="$(tput setaf 2)"
    COL_RED="$(tput setaf 1)"
    COL_YELLOW="$(tput setaf 3)"
    COL_BLUE="$(tput setaf 4)"
    COL_RESET="$(tput sgr0)"
fi

GLOBAL_LOG=""
# Will be overwritten to -e in case debug mode is on, this will print command before execution
AUGTOOL_DEBUG="${AUGTOOL_DEBUG:-}"

debug () {
    if [[ "${DEBUG:-0}" != 0 ]]; then
        echo -e "${COL_BLUE:-}$@${COL_RESET:-}" >&2
    fi
}

info (){
    echo -e "${COL_GREEN:-}$@${COL_RESET:-}" >&2
}

warn () {
    echo -e "${COL_YELLOW:-}$@${COL_RESET:-}" >&2
}

fatal () {
    echo -e "${COL_RED:-}$@${COL_RESET:-}" >&2
    echo -e "${COL_RED:-}$@${COL_RESET:-}"
}

clean_log () {
    GLOBAL_LOG=""
}

log_set_variable () {
    if [[ -z "${1:-}" ]]; then
      fatal "common/helpers: Please provide variable name as parameter"
      exit 10
    fi

    VAR_NAME=${1}
    VAR_VALUE="${!VAR_NAME}"
    GLOBAL_LOG="${GLOBAL_LOG} $VAR_NAME '${VAR_VALUE:-}'"
}

print_log () {
    if [[ "${DEBUG:-0}" == 0 ]]; then
        return 0
    fi

    echo -e "${COL_BLUE:-}"
    LOG_CMD="${1:-}"
    HEADER_TEXT="${LOG_CMD}: ${2:-Variables set by running ${LOG_CMD:-} command:}"
    divider===============================
    divider=$divider$divider
    header="\n %-50s \n"
    format=" %-25s %25s \n"
    width=50
    printf "$header" "${HEADER_TEXT}"
    printf "%$width.${width}s\n" "$divider"
    printf "$format" ${GLOBAL_LOG}
    printf "NOTE: Variables are printed in the order they are applied, the last value counts.\n"
    echo -e "${COL_RESET:-}"
}

vercomp () {
    if [[ $1 == $2 ]]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Install tarball in format path/somthing-<version>.<extension>
# so version is after last occurence of - followed by .extension
parse_version () {
    FILE_PATH="${1}"
    EXTENSION="${2}"
    case ${PRODUCT} in
        "coverity"|"fisheye"|"artifactory")
            echo ${FILE_PATH//*-} | sed s/${EXTENSION}//
            ;;
        *)
            PRODUCT_TO_CHECK="${PRODUCT}"
            if [[ "${FILE_PATH}" == *"atlassian-stash-"* ]]; then
                PRODUCT_TO_CHECK="stash"
            fi
            if [[ 1 -eq ${EARLY_ACCESS:-0} ]]; then
                echo ${FILE_PATH//*${PRODUCT_TO_CHECK}-} | cut -d - -f 1
            else
                echo ${FILE_PATH//*${PRODUCT_TO_CHECK}-} | sed s/${EXTENSION}//
            fi
        ;;
    esac
    return 0
}

# If version is not provided, tries to parse it and checks if it is in correct format
parse_and_test_version () {
    EXTENSION="${1}"
    if [[ -z "${VERSION:-}" ]]; then
        warn "VERSION has to be provided for atlassian applications. Trying to parse it from tarball filename ${TARBALL}"
        VERSION=$(parse_version ${TARBALL} ${EXTENSION})
    fi
    
    # Check VERSION is in format dd.dd.dd
    VERSION_CHECKED=$(echo ${VERSION} | sed -r '/^[0-9]+\.[0-9]+[.0-9]*.*$/d')
    if [[ ! -z "${VERSION_CHECKED}" ]] ; then
        fatal "Can not determine new version or it is not in the right format, please use XX.XX.XX format (ie: 4.15.3). Found: ${VERSION}"
        exit 23
    fi

}

# Evaluates version comparison 
# Params:  
#   version1 <operator> version2
# 
# Example:
# 1.3.4 > 1.4.2  => returns 1
# 
version_comparison () {
    vercomp $1 $3
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != $2 ]]; then
        return 1
    else
        return 0
    fi
}

check_versions () {
    set +e
    version_comparison "${1}" "<" "${2}" 
    if [[ $? != 0 ]]; then
        set -e
        fatal "Provided version is lower or equal to currently installed version of the application. \
        Check avst-app.cfg.sh for version you are trying to upgrade to or \
        use --allow-downgrade if you are 100% sure: Installed: ${1} Upgrade to: ${2}"
        return 34 
    fi
    set -e
}

create_instance_rc () {
    # In case the specific rc dir exists ignore, otherwise create it and add all scripts for command
    for _CMD_RC in "modify" "start" "stop"; do
        if [[ -d "${INSTANCE_DIR}/avst-app/rc/${_CMD_RC}.d" ]]; then
            debug "common/install/create_instance_rc: Rc file ${INSTANCE_DIR}/avst-app/rc/${_CMD_RC}.d exists, ignoring..."
        else
            debug "common/install/create_instance_rc: creating instance rc for: $_CMD_RC"
            mkdir -p "${INSTANCE_DIR}/avst-app/rc/${_CMD_RC}.d"

            # Add additional directories that may contain the command
            if [[ ! -z "${ADDITIONAL_CFGS:-}" ]]; then
                ADDITIONAL_DIRS=""
                for _dir in ${ADDITIONAL_CFGS} ; do
                    ADDITIONAL_DIRS="${ADDITIONAL_DIRS:-} ${_dir}/${_CMD_RC}"
                done
            fi

            for script in $( eval echo $( find_scripts \
                "${SHARE_DIR}/lib/common/${_CMD_RC}" \
                "${SHARE_DIR}/lib/product/${PRODUCT}/${_CMD_RC}" \
                $( echo ${ADDITIONAL_DIRS:-} ) \
                "${INSTANCE_DIR}/avst-app/lib/${_CMD_RC}" ) ) ; do
                debug "common/install/create_instance_rc ${_CMD_RC}: linking \"${script}\""
                ( cd "${INSTANCE_DIR}/avst-app/rc/${_CMD_RC}.d" && ln -sf "${script}" ./ )
            done
        fi
    done
}

parse_installed_avst_app_version () {
    INIT_HOME="${INIT_HOME:-/etc}"
    if [[ -f "${INIT_HOME}/redhat-release" ]]; then
        INSTALLED_AVSTAPP_CMD='rpm -qi avst-app'
    elif [[ -f "${INIT_HOME}/debian_version" ]]; then
        INSTALLED_AVSTAPP_CMD='dpkg -s avst-app'
    else
        fatal "Unsupported OS, contact support team"
        exit 36
    fi
    CURRENTLY_INSTALLED_VERSION=`${INSTALLED_AVSTAPP_CMD} | grep Version`
    echo ${CURRENTLY_INSTALLED_VERSION:-}
    return 0
}

check_avstapp_version () {
    CURRENTLY_INSTALLED_VERSION=`parse_installed_avst_app_version`
    if [[ -f "${INSTANCE_DIR}/.avstapp_version" ]]; then 
        AVSTAPP_CONFIGURED_FOR_VERSION=$( head -1 "${INSTANCE_DIR}/.avstapp_version" )

        if [[ ${CURRENTLY_INSTALLED_VERSION} != ${AVSTAPP_CONFIGURED_FOR_VERSION} ]]; then
            warn "shared/startup.cfg.d/check_avstapp_version: Version of currently installed avst-app does not match the version of the configuration, there may be new scripts in rc folder,\n
            we recommend to run 'avst-app ${INSTANCE_NAME} regeneraterc' command to make use of the latest avst-app features. In case you customised rc scripts, make sure you merge the changes in after rc regeneration"
        fi
    else
        debug "shared/startup.cfg.d/check_avstapp_version: File ${INSTANCE_DIR}/.avstapp_version does not exist, probably this feature does not exist in your version of avst-app, creating it now, \n
        it is recommended to run 'avst-app ${INSTANCE_NAME} regeneraterc' command to make use of the latest avst-app features."
        # For backwards compatibility, create avstapp_version file if not present
        echo "${CURRENTLY_INSTALLED_VERSION}" > "${INSTANCE_DIR}/.avstapp_version"
    fi
}

# Allows to run commands returning non 0 status and mock them if needed
# Always returns status 0, actual status and value can be parsed using get_std_out and get_std_return methods
run_cmd () {
    set +e
    RET=$( { eval ${MOCK_CMD:-} $@; } 2>&1)
    RET_STATUS="${?}"
    echo "${MOCK_RETURN_STATUS:-${RET_STATUS}}:${RET}${MOCK_RETURN_VALUE:-}"
    [[ $RET_STATUS != 0 ]] && warn "Non-zero exit value whilst running \"$@\""
    MOCK_CMD=""
    MOCK_RETURN_VALUE=""
    MOCK_RETURN_STATUS=""
    set -e
    return 0
}

get_std_return () {
    CMD_RESULT="${1}"
    echo $(echo "${CMD_RESULT}" | cut -f 1 -d ":")
}

get_std_out () {
    CMD_RESULT="${1}"
    echo ${CMD_RESULT#*:}
}

update_state () {
    echo "${1}" > "${INSTANCE_DIR}/.state"
    debug "Setting state to ${1}"
}

update_version () {
    echo "${1}" > "${INSTANCE_DIR}/.version"
    debug "Setting version to ${1}"    
}

stop_service () {
    debug "Stopping service ${INSTANCE_NAME}"
    RESULT_SERVICE_STOP=$( run_cmd service "${INSTANCE_NAME}" stop )
    if [[ $(get_std_return ${RESULT_SERVICE_STOP}) != "0" ]]; then
        fatal "Can not stop service, check logs for more details, probably unrecognized: $(get_std_out ${RESULT_SERVICE_STOP})"
        exit 45
    fi
}

start_service () {
    debug "Starting service ${INSTANCE_NAME}"
    RESULT_SERVICE_START=$( run_cmd service "${INSTANCE_NAME}" start )
    if [[ $(get_std_return ${RESULT_SERVICE_START}) != "0" ]]; then
        fatal "Can not start service, check logs for more details, probably unrecognized: $(get_std_out ${RESULT_SERVICE_START})"
        exit 46
    fi
}

initiate_git_repo () {
    if [[ "${GIT_AVST_KEEPER:-0}" != 0 ]]; then
        if [[ ! -d "${INSTANCE_DIR}/.git" ]]; then
            if [[ -z "${REMOTE_GIT_REPO:-}" ]]; then
                fatal "initiate_git_repo: Please provide REMOTE_GIT_REPO with path to remote git repository"
                exit 11
            fi
            CURRENT_DIR=$(pwd)
            cd "${INSTANCE_DIR}"
            echo "initializing"
            git init
            #create .gitignore only if it does not exist  
            if [[ ! -f ".gitignore" ]]; then
                cat <<EOF > .gitignore
install/logs/
install/work/
install/temp/
install/trash/
install/var
install/nohup.out
install/cache
install/apache-tomcat/logs/
install/apache-tomcat/work/
install/apache-tomcat/temp/
home/*
!home/fisheye.cfg.xml
!home/crowd.cfg.xml
!home/crowd.properties
EOF
            fi
            git remote add origin "${REMOTE_GIT_REPO}"
            push_change_history "Initial commit"
            cd "${CURRENT_DIR}"
        fi
    fi
}

push_change_history () {
    if [[ "${GIT_AVST_KEEPER:-0}" != 0 ]]; then
        MESSAGE="${1:-}"
        CURRENT_DIR=$(pwd)
        cd "${INSTANCE_DIR}"
        GIT_BRANCH_NAME="${REMOTE_GIT_BRANCH:-master:${INSTANCE_NAME}}"
        if [[ -d "${INSTANCE_DIR}/.git" ]]; then
            git add -A
            git commit -m "Changes from date `date`: ${MESSAGE}"
            git push origin "${GIT_BRANCH_NAME}"
        else
            initiate_git_repo
        fi
        cd "${CURRENT_DIR}"
    fi
}

function find_scripts () {
    debug "common/env.sh: find_scripts: testing the following locations \"$@\""

    if [[ -z "${1:-}" ]]; then
        # No params given
        warn "common/env.sh: find_scripts: called with no params"
        return 1
    elif [[ -x "$1" ]]; then
        debug "common/env.sh: find_scripts: returning script list of: \"${1}\""
        echo "\"${1}\""
        return 0
    fi

    dirlist=""
    for arg in $@ ; do
        _dir="${arg}.d"
        if [[ -d "${_dir}" ]]; then
            debug "common/env.sh: find_scripts: Directory \"${_dir}\" exists looking for scripts within it"
            dirlist="${dirlist:-} \"${_dir}\""
        else
            debug "common/env.sh: find_scripts: Directory \"${_dir}\" does not exist - ignoring"
        fi
    done
    debug "common/env.sh: find_scripts: Candidate directores are now: ${dirlist}"

    # "eval echo" because the dir list has quotes in, such that the filenames can contain spaces
    # find is used here to avoid blank lines in ouput given by globbing
    # The final awk | sort | cut is used to sort on filename
    if [[ ! -z "${dirlist}" && "" != "${dirlist}" ]]; then
        for cfg in $( \
            find $( eval echo ${dirlist} ) -mindepth 1 -maxdepth 1 -print -type f -o -type l | \
            awk -F/ '{print $NF,$0}' | sort | cut -f2- -d' ' \
        ) ; do
            if [[ -r "${cfg}" ]]; then
                debug "common/env.sh: find_scripts: Adding script \"${cfg}\" to script list"
                list="${list:-} \"${cfg}\""
            else
                warn "common/env.sh: find_scripts: \"${cfg}\" was not readable when attempting to source it"
            fi
        done
    fi
    debug "common/env.sh: find_scripts: returning script list of:\n  $( echo ${list:-} | sed -e's/ /\n  /g' )\n"
    echo ${list:-}
    return 0
}

function get_pid () {
    set +e
    if [ "${PRODUCT}" == "sonarqube" ]; then
        PID=$(pgrep -of "java.*${INSTANCE_NAME}\W")
    elif [ "${PRODUCT}" == "bambo_agent" ]; then
        PID=$(pgrep -of "java.*${INSTANCE_NAME}\W")
    else
        PID=$(pgrep -nf "^${INSTANCE_NAME}\W")
    fi
    set -e

    if [[ -z ${PID} || ${PID} -eq 1 ||  ! $( ps -p"${PID}" -o pid= ) ]]; then
        PID=0
    fi

    # TODO: validate that this is a valid and correct applicaiton pid

    echo ${PID}
    return 0
}

function signal_stop_process () {
    APP_PID=$(get_pid)
    MESSAGE_TAG=$1
    if [[ -z ${APP_PID} || ${APP_PID} -lt 2  || ! $( ps -p"${APP_PID}" -o pid= ) ]]; then
        fatal "${MESSAGE_TAG}: The stop command failed and the specified process ID \"${APP_PID}\" is not valid so a manual kill is not possible"
        exit 20
    else
        debug "${MESSAGE_TAG}: The stop command failed, Attempting to signal the process (\"${APP_PID}\") to stop through OS signal."
        kill -15 "${APP_PID}" >/dev/null 2>&1
    fi
}

# Retrieves access token to running jira instance
function get_application_access_token () {
    APPLICATION_URL="${1}"
    APPLICATION_ADMIN_USER="${2}"
    APPLICATION_ADMIN_PASS="${3}"
    URL="${APPLICATION_URL}/rest/plugins/1.0/?os_authType=basic"

    shopt -s extglob # Required to trim whitespace; see below

    while IFS=':' read key value; do
        # trim whitespace in "value"
        value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}
        case "$key" in
            'upm-token') TOKEN="$value"
                    ;;
         esac
    done < <(curl --silent -i -H "Accept: application/vnd.atl.plugins.installed+json" \
        -X GET -u "${APPLICATION_ADMIN_USER}:${APPLICATION_ADMIN_PASS}" "${URL}")
    
    if [[ -z "${TOKEN}" ]]; then
        fatal "Can not retrieve upm-token from ${URL}"
        exit 14
    fi
    echo ${TOKEN}
    return 0 
}

function install_plugin () {
    PLUGIN_KEY="${1}"
    PLUGIN_BUILD_NUMBER="${2}"
    TOKEN="${3}"
    APPLICATION_URL="${4}"
    APPLICATION_ADMIN_USER="${5}"
    APPLICATION_ADMIN_PASS="${6}"
    URL="${APPLICATION_URL}/rest/plugins/1.0/?token=${TOKEN}"
    PLUGIN_URL="https://marketplace.atlassian.com/download/plugins/${PLUGIN_KEY}/version/${PLUGIN_BUILD_NUMBER}"
    RESP=$(curl -i -s -o /dev/null -w "%{http_code}" -H "Accept: application/json" -H "Content-Type: application/vnd.atl.plugins.install.uri+json"  \
        -X POST -u "${APPLICATION_ADMIN_USER}:${APPLICATION_ADMIN_PASS}" \
        -d "{\"pluginUri\":\"${PLUGIN_URL}\"}" \
        "${URL}")
    if [[ "${RESP}" != "202" ]]; then
        fatal "Installation of plugin ${PLUGIN_KEY} failed with response code ${RESP}"
        exit 14
    else
        debug "Installation of plugin ${PLUGIN_KEY} ok"
    fi
}

function plugin_installation_completed () {
    PLUGIN_KEY="${1}"
    APPLICATION_URL="${2}"
    APPLICATION_ADMIN_USER="${3}"
    APPLICATION_ADMIN_PASS="${4}"
    URL="${APPLICATION_URL}/rest/plugins/1.0/${PLUGIN_KEY}-key/summary"
    for i in {1..10}
    do
        RESP=$(curl -i -s -o /dev/null -w "%{http_code}" -H "Accept: application/vnd.atl.plugins+json"  \
            -X GET -u "${APPLICATION_ADMIN_USER}:${APPLICATION_ADMIN_PASS}" \
            "${URL}")
        if [[ "${RESP}" != "200" ]]; then
            warn "Plugin not yet installed, response code ${RESP}, waiting..."
            sleep 10
        else
            debug "Plugin installed and ready to use."
            break
        fi
    done
}

function install_plugin_license () {
    PLUGIN_KEY="${1}"
    PLUGIN_LICENSE="${2}"
    APPLICATION_URL="${3}"
    APPLICATION_ADMIN_USER="${4}"
    APPLICATION_ADMIN_PASS="${5}"
    URL="${APPLICATION_URL}/rest/plugins/1.0/${PLUGIN_KEY}-key/license"
    RESP=$(curl -i -s -o /dev/null -w "%{http_code}" -H "Accept: application/json" \
        -H "Content-Type: application/vnd.atl.plugins+json"  \
        -X POST -u "${APPLICATION_ADMIN_USER}:${APPLICATION_ADMIN_PASS}" \
        -d "{\"rawLicense\":\"${PLUGIN_LICENSE}\"}" \
        "${URL}")
    if [[ "${RESP}" != "200" ]]; then
       fatal "Installation of plugin license ${PLUGIN_KEY} failed with response code ${RESP}"
       exit 14
   else
        debug "Installation of plugin license ${PLUGIN_KEY} ok"
    fi
}

function fetch_build_number_from_marketplace () {
    PLUGIN_KEY="${1}"
    PLUGIN_VERSION="${2}"
    MARKETPLACE_USER="${3}"
    MARKETPLACE_PASS="${4}"
    MARKETPLACE_URL="https://marketplace.atlassian.com"
    MARKETPLACE_ADDONS_URL="${MARKETPLACE_URL}/rest/2/addons"

    if [[ "${PLUGIN_VERSION}" == "latest" ]]; then
        URL="${MARKETPLACE_ADDONS_URL}/${PLUGIN_KEY}/versions/latest"
    else
        URL="${MARKETPLACE_ADDONS_URL}/${PLUGIN_KEY}/versions/name/${PLUGIN_VERSION}"
    fi
    
    RESP=$(curl -s -H "Accept: application/json" \
        -X GET -u "${MARKETPLACE_USER}:${MARKETPLACE_PASS}" \
        "${URL}")
    
    PLUGIN_BUILD_NUMBER=$(echo "${RESP}" | sed s/,/\\n/g | grep "buildNumber" | sed s/\"buildNumber\"://)

    if [[ -z "${PLUGIN_BUILD_NUMBER:-}" ]]; then
        fatal "Can not retrieve build number for ${PLUGIN_KEY} ${PLUGIN_VERSION}"
        exit 14
    fi
    echo "${PLUGIN_BUILD_NUMBER}"
}


