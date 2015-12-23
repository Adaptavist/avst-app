#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "On RedHat, create ln for specific upstart file in init" {
    # mock redhat os
    INIT_HOME="/tmp/init_test"
    INSTANCE_NAME="testing"
    mkdir -p "${INIT_HOME}/init"

    SHARE_DIR="../share/avst-app"
    touch "${INIT_HOME}/redhat-release"

    source ../share/avst-app/lib/common/install-service.d/10create_upstart_link
    
    [[ -L "${INIT_HOME}/init/${INSTANCE_NAME}.conf" ]]
    [[ $(grep "start on (local-filesystems and net-device-up IFACE!=lo)" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep "respawn limit 10 5" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep "kill timeout 120" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep 'exec avst-app $UPSTART_JOB start' "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]

    # cleanup
    rm -fr "${INIT_HOME}"
}


@test "On Debian, create ln for specific upstart file in init" {
    # mock debian os
    INIT_HOME="/tmp/init_test"
    mkdir -p "${INIT_HOME}/init"
    INSTANCE_NAME="testing"

    SHARE_DIR="../share/avst-app"
    touch "${INIT_HOME}/debian_version"

    source ../share/avst-app/lib/common/install-service.d/10create_upstart_link
    [[ -L "${INIT_HOME}/init/${INSTANCE_NAME}.conf" ]]
    [[ $(grep "start on (local-filesystems and net-device-up IFACE!=lo)" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep "respawn limit 10 5" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep "kill timeout 120" "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep 'exec avst-app $UPSTART_JOB start' "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep 'oom score -999' "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]
    [[ $(grep 'console log' "${SHARE_DIR}/upstart/${UPSTART_FILE}") ]]

    # cleanup
    rm -fr "${INIT_HOME}"
}

@test "Fails if not redhat or debian" {
    # mock unsupported os
    INIT_HOME="/tmp/init_test"
    mkdir -p "${INIT_HOME}/init"

    SHARE_DIR="../share/avst-app"

    run source ../share/avst-app/lib/common/install-service.d/10create_upstart_link
    assert_fail
    [[ "${status}" == 36 ]]
    [[ "${output}" == *"Unsupported OS"* ]]

    # cleanup
    rm -fr "${INIT_HOME}"
}

