#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "parses version from filename if not provided" {
    INSTANCE_DIR="/tmp"
    TARBALL="/tmp/atlassian-confluence-5.4.tar.gz"
    source ../share/avst-app/lib/atlassian/install.d/04update_version
    [[ "${VERSION}" == "5.4" ]]
    VER_SET=$( head -1 "${INSTANCE_DIR}/.version" )
    [[ "${VERSION}" == "${VER_SET}" ]]
    # cleanup
    rm -f "${INSTANCE_DIR}/.version"
}

@test "version must have dd.dd format" {
    INSTANCE_DIR="/tmp"
    VERSION="5.12"
    run source ../share/avst-app/lib/atlassian/install.d/04update_version
    assert_success
    VER_SET=$( head -1 "${INSTANCE_DIR}/.version" )
    [[ "${VERSION}" == "${VER_SET}" ]]
    # cleanup
    rm -f "${INSTANCE_DIR}/.version"
}

@test "version must have dd.dd.dd format" {
    INSTANCE_DIR="/tmp"
    VERSION="5.12.18"
    run source ../share/avst-app/lib/atlassian/install.d/04update_version
    assert_success
    VER_SET=$( head -1 "${INSTANCE_DIR}/.version" )
    [[ "${VERSION}" == "${VER_SET}" ]]
    # cleanup
    rm -f "${INSTANCE_DIR}/.version"
}

@test "fails if version is not numbers based" {
    INSTANCE_DIR="/tmp"
    VERSION="5.12.1x"
    run source ../share/avst-app/lib/atlassian/install.d/04update_version
    assert_fail
    [[ "${status}" == 23 ]]
    [[ "${output}" == *"please use XX.XX.XX format"* ]]
}

@test "fails if parsed version is not in correct format" {
    INSTANCE_DIR="/tmp"
    TARBALL="/tmp/atlassian-confluence-5.4x.4.tar.gz"
    run source ../share/avst-app/lib/atlassian/install.d/04update_version
    assert_fail
    [[ "${status}" == 23 ]]
    [[ "${output}" == *"please use XX.XX.XX format"* ]]
}

