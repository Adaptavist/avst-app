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
# Setup environment for all scripts
# Note: /etc/default/avst-app must be sourced before this

## Globals (i.e. not instance specific)
# Belt and braces check we've been called correctly
if [[ -z "${INSTANCE_NAME:-}" ]]; then
    fatal "env.sh: INSTANCE_NAME not set, exiting"
    exit 1
elif [[ -z "${BASE_DIR:-}" ]]; then
    fatal "env.sh: BASE_DIR not set, exiting"
    exit 1
elif [[ -z "${INSTANCE_DIR:-}" ]]; then
    fatal "env.sh: INSTANCE_DIR not set, exiting"
    exit 1
fi

log_set_variable SHARE_DIR
log_set_variable BASE_DIR
log_set_variable INSTANCE_NAME
log_set_variable INSTANCE_DIR
log_set_variable INSTANCE_USER
log_set_variable INSTANCE_GROUP

## Instance specifics
# First bring in the user-settings
if [[ ! -r "${INSTANCE_DIR}/avst-app.cfg.sh" ]]; then
    fatal "env.sh: Instance ${INSTANCE_NAME} is not configured (unable to read \"${INSTANCE_DIR}/avst-app.cfg.sh\""
    exit 10
else
    debug "env.sh: sourcing \"${INSTANCE_DIR}/avst-app.cfg.sh\""
    . "${INSTANCE_DIR}/avst-app.cfg.sh"
fi

if [[ -z "${PRODUCT}" ]]; then
    fatal "env.sh: Mandatory var: PRODUCT not set in \"${INSTANCE_DIR}/avst-app.cfg.sh\""
    exit 10
fi

# if a specific path to the java binary is not provided fall back to just java and 
# let the system work it out
JAVA_BIN=${JAVA_BIN:-"java"}

log_set_variable JAVA_BIN
print_log "Default fallback" "Global defaults are:"

# create avst-app/rc/startup.cfg if it does not exists and simlink all startup files into it
# source special files from 00add_dependencies and add ADDITIONAL_CFGS too
# do this only when in install phase
if [[ "${_CMD}" == "install" || "${_CMD}" == "prepare" || "${_CMD}" == "regeneraterc" ]]; then
    if [[ ! -d "${INSTANCE_DIR}/avst-app/rc/startup.d" ]]; then
        mkdir -p "${INSTANCE_DIR}/avst-app/rc/startup.d"
        
        # Now bring in all the defaults
        for s in $( eval echo $( find_scripts \
            "${SHARE_DIR}/lib/product/${PRODUCT}/startup.cfg" \
            "${SHARE_DIR}/lib/common/startup.cfg" ) ) ; do
            # special case for 00add_dependencies
            file_name=`basename ${s}`
            debug "CHECKING: ${file_name} for dependencies"
            if [[ "${file_name}" == *"add_dependencies"* ]]; then
                debug "env.sh: Adding dependencies from ${s}"
                . "${s}"
            fi
            debug "env.sh: Adding ${s} to avst-app/rc/startup.cfg"
            ( cd "${INSTANCE_DIR}/avst-app/rc/startup.d" && ln -sf "${s}" ./ )
            
        done

        # ADDITIONAL_CFGS needs to be set by the above scripts to include app-server etc
        debug "env.sh: Additional config areas are: ${ADDITIONAL_CFGS:-}"
        ADDITIONAL_STARTUP_CFGS=""
        for dir in ${ADDITIONAL_CFGS:-} ; do
            if [[ -d "${dir}/startup.cfg.d" ]]; then
                ADDITIONAL_STARTUP_CFGS="${dir}/startup.cfg ${ADDITIONAL_STARTUP_CFGS:-}"
            else
                warn "env.sh: Additional dir provided but no environment given (i.e. \"${dir}/startup.cfg.d\" does not exist"
            fi
        done
        debug "env.sh: Additional config areas are: ${ADDITIONAL_STARTUP_CFGS}"
        for s in $( eval echo $( find_scripts ${ADDITIONAL_STARTUP_CFGS} ) ) ; do
            debug "env.sh: Linking ${s} to rc/startup.cfg"
            ( cd "${INSTANCE_DIR}/avst-app/rc/startup.d" && ln -sf "${s}" ./ )
        done
    else
        debug "env.sh: ${INSTANCE_DIR}/avst-app/rc/startup.d already exists, ignoring..."
    fi
fi

# source all scripts from avst-app/rc/startup.d
for script in $( eval echo $( find_scripts ${INSTANCE_DIR}/avst-app/rc/startup ) ) ; do
    debug "avst-app: Sourcing ${script}"
    . "${script}"
done

print_log "startup.cfg"

