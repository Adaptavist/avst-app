#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "in case service is already running do not start it again" {
    DEBUG=1
    INSTANCE_NAME="test_service_name"
    MOCK_CMD='echo'
    MOCK_RETURN_VALUE="Service is running"
    MOCK_RETURN_STATUS="1"
    run source ../share/avst-app/lib/common/upgrade.d/99start_service
    assert_success
    echo "${output}"
    [[ "${output}" == *"service '${INSTANCE_NAME}' status | grep stop"* ]]
    [[ "${output}" != *"start_service"* ]]
}

@test "if service is not running start it" {
    DEBUG=1
    INSTANCE_NAME="testing_stuff"
    MOCK_CMD='echo'
    MOCK_RETURN_VALUE="Service is not running"
    MOCK_RETURN_STATUS="0"
    run source ../share/avst-app/lib/common/upgrade.d/99start_service
    assert_success
    echo "${output}"
    [[ "${output}" == *"service '${INSTANCE_NAME}' status | grep stop"* ]]
    [[ "${output}" == *"start_service"* ]]
}
