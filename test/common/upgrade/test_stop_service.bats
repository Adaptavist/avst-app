#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "make sure service is not running" {
    # enable debug to test result of run_cmd
    DEBUG=1
    INSTANCE_NAME="testing_stuffasdasdgadaf"
    INSTANCE_DIR="/tmp/test_stop_service"
    mkdir -p "${INSTANCE_DIR}"

    MOCK_CMD='echo'
    MOCK_RETURN_VALUE="Service is not running"
    MOCK_RETURN_STATUS="1"
    run source ../share/avst-app/lib/common/upgrade.d/60stop_service
    assert_success
    # assuming it is not running
    echo "${output}"
    [[ "${output}" == *"service '${INSTANCE_NAME}' status | grep running"* ]]
    [[ "${output}" != *"stop_service"* ]]
    [[ $(grep upgrading ${INSTANCE_DIR}/.state) ]]
    rm -rf "${INSTANCE_DIR}"
}

@test "if service is running, stop it" {
    DEBUG=1
    INSTANCE_NAME="testing_stuff"
    INSTANCE_DIR="/tmp/test_stop_service"
    mkdir -p "${INSTANCE_DIR}"
    MOCK_CMD=echo
    MOCK_RETURN_VALUE="Service is running"
    MOCK_RETURN_STATUS="0"
    RUNNING=true
    run source ../share/avst-app/lib/common/upgrade.d/60stop_service
    assert_success
    echo "${output}"
    [[ "${output}" == *"stop_service"* ]]
    [[ "${output}" == *"service '${INSTANCE_NAME}' status | grep running"* ]]
    [[ $(grep upgrading ${INSTANCE_DIR}/.state) ]]
    rm -rf "${INSTANCE_DIR}"
}
