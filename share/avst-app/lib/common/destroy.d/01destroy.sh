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

if [[ ! -z "${INSTANCE_DIR}" ]]; then
    if [[ -d "${INSTANCE_DIR}/install" ]]; then
        rm -rf "${INSTANCE_DIR}/install"
        debug "destroy: deleted ${INSTANCE_DIR}/install"
    fi
    if [[ -d "${INSTANCE_DIR}/home" ]]; then
        rm -rf "${INSTANCE_DIR}/home"
        debug "destroy: deleted ${INSTANCE_DIR}/home"
    fi
    if [[ -d "${INSTANCE_DIR}/avst-app" ]]; then
        rm -rf "${INSTANCE_DIR}/avst-app"
        debug "destroy: deleted ${INSTANCE_DIR}/avst-app"
    fi
    if [[ -f "${INSTANCE_DIR}/.state" ]]; then
        rm -f "${INSTANCE_DIR}/.state"
        debug "destroy: deleted ${INSTANCE_DIR}/.state"
    fi
    if [[ -f "${INSTANCE_DIR}/.version" ]]; then
        rm -f "${INSTANCE_DIR}/.version"
        debug "destroy: deleted ${INSTANCE_DIR}/.version"
    fi
fi

