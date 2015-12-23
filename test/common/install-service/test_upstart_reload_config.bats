#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "should reload initctl configuration" {
    DEBUG=1
    MOCK_CMD='echo'
    run source ../share/avst-app/lib/common/install-service.d/15upstart_reload_config
    assert_success
    echo "${output}"
    [[ "${output}" == *"initctl reload-configuration"* ]]
}

