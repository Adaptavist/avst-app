#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "destroy removes install, home, avst-app, .version and .state" {
    INSTANCE_DIR="/tmp/avst_test"
    mkdir -p "${INSTANCE_DIR}/home" "${INSTANCE_DIR}/install" "${INSTANCE_DIR}/avst-app" 
    touch "${INSTANCE_DIR}/.state"
    touch "${INSTANCE_DIR}/.version"
    run source ../share/avst-app/lib/common/destroy.d/01destroy.sh
    assert_success
    [[ ! -f "${INSTANCE_DIR}/.state" ]]
    [[ ! -f "${INSTANCE_DIR}/.version" ]]
    [[ ! -d "${INSTANCE_DIR}/install" ]]
    [[ ! -d "${INSTANCE_DIR}/home" ]]
    [[ ! -d "${INSTANCE_DIR}/avst-app" ]]
    # cleanup
    rm -fr "${INSTANCE_DIR}"
}

