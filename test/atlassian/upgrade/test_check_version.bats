#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "if ALLOW_DOWNGRADE is set, new version can be lower or same then old version" {
    INSTANCE_DIR="/tmp"
    ALLOW_DOWNGRADE=1
    cat <<EOF > "${INSTANCE_DIR}/.version"
    5.5.1
EOF
    TARBALL="/tmp/atlassian-confluence-5.4.tar.gz"
    run source ../share/avst-app/lib/atlassian/upgrade.d/51check_version
    assert_success
    # cleanup
    rm -f "${INSTANCE_DIR}/.version"
}

@test "if ALLOW_DOWNGRADE is not set, new version must be greater then old version" {
    INSTANCE_DIR="/tmp"
    cat <<EOF > "${INSTANCE_DIR}/.version"
    5.5.1
EOF
    TARBALL="/tmp/atlassian-confluence-5.4.tar.gz"
    run source ../share/avst-app/lib/atlassian/upgrade.d/51check_version
    assert_fail
    echo "${output}"
    [[ "${output}" == *"Provided version is lower or equal to currently installed version of the application"* ]]
    # cleanup
    rm -f "${INSTANCE_DIR}/.version"
}

