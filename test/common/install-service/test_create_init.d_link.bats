#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "On RedHat, create upstart script with initctl" {
    # mock redhat os
    INIT_HOME="/tmp/init_test"
    INSTANCE_NAME="testing"
    mkdir -p "${INIT_HOME}/init.d"

    touch "${INIT_HOME}/redhat-release"

    source ../share/avst-app/lib/common/install-service.d/20create_init.d_link
    
    [[ $(grep 'initctl $1 $( basename $0 )' "${INIT_HOME}/init.d/${INSTANCE_NAME}") ]]
    
    # cleanup
    rm -fr "${INIT_HOME}"
}


@test "On Debian, create ln upstart file in init.d" {
    # mock redhat os
    INIT_HOME="/tmp/init_test"
    LIB_HOME="/tmp/init_test_lib"
    mkdir -p "${INIT_HOME}/init.d" "${LIB_HOME}/init"
    touch "${LIB_HOME}/init/upstart-job"
    INSTANCE_NAME="testing"
    touch "${INIT_HOME}/debian_version"

    source ../share/avst-app/lib/common/install-service.d/20create_init.d_link
    [[ -L "${INIT_HOME}/init.d/${INSTANCE_NAME}" ]]
    
    # cleanup
    rm -fr "${INIT_HOME}"
    rm -rf "${LIB_HOME}"
}

@test "Fails if not redhat or debian" {
    # mock unsupported os
    INIT_HOME="/tmp/init_test"
    mkdir -p "${INIT_HOME}/init.d"

    INSTANCE_NAME="testing"

    run source ../share/avst-app/lib/common/install-service.d/20create_init.d_link
    assert_fail
    echo "${output}"
    [[ "${status}" == 36 ]]
    [[ "${output}" == *"Unsupported OS"* ]]

    # cleanup
    rm -fr "${INIT_HOME}"
}

