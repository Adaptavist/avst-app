#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Changes state to modified" {
    INSTANCE_DIR="/tmp/modify_test"
    mkdir -p "${INSTANCE_DIR}"

    source ../share/avst-app/lib/common/modify.d/99update_state
    
    [[ $(grep 'modified' "${INSTANCE_DIR}/.state") ]]
    
    # cleanup
    rm -fr "${INSTANCE_DIR}"
}

