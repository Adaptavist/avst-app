#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Should fail if install dir already exists" {
    INSTALL_DIR="/tmp/install_test"
    HOME_DIR="/tmp/home_test"

    mkdir -p "${INSTALL_DIR}"

    run source ../share/avst-app/lib/common/install.d/02create_dirs
    assert_fail
    [[ "${status}" == 10 ]]
    [[ "${output}" == *"already exists"* ]]
    
    # cleanup
    rm -fr "${INSTALL_DIR}"
    rm -fr "${HOME_DIR}"
}


@test "Should fail if home dir already exists" {
    INSTALL_DIR="/tmp/install_test"
    HOME_DIR="/tmp/home_test"

    mkdir -p "${HOME_DIR}"

    run source ../share/avst-app/lib/common/install.d/02create_dirs
    assert_fail
    [[ "${status}" == 10 ]]
    [[ "${output}" == *"already exists"* ]]
    
    # cleanup
    rm -fr "${INSTALL_DIR}"
    rm -fr "${HOME_DIR}"
}

@test "Should create home and install dir" {
    INSTALL_DIR="/tmp/install_test"
    HOME_DIR="/tmp/home_test"

    run source ../share/avst-app/lib/common/install.d/02create_dirs
    assert_success
    [[ -d "${INSTALL_DIR}" ]]
    [[ -d "${HOME_DIR}" ]]
    
    # cleanup
    rm -fr "${INSTALL_DIR}"
    rm -fr "${HOME_DIR}"
}

