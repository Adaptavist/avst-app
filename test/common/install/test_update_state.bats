#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Changes state to installed" {
    INSTANCE_DIR="/tmp/install_test"
    mkdir -p "${INSTANCE_DIR}"

    source ../share/avst-app/lib/common/install.d/99update_state
    
    [[ $(grep 'installed' "${INSTANCE_DIR}/.state") ]]
    
    # cleanup
    rm -fr "${INSTANCE_DIR}"
}

