#!/usr/bin/env bats

load ../test_helper

setup() {
    # source functions to test
    source ../share/avst-app/lib/common/helpers.sh
}

@test "parses return value from string that is first field with : delimiter" {
    RET_VALUE='5'
    TEST_STRING="${RET_VALUE}:tralalalala"
    run get_std_return "${TEST_STRING}"
    assert_success
    echo "${output}"
    [[ "${output}" == "${RET_VALUE}" ]]
    [[ "${status}" == 0 ]]
}

@test "parses std out from string that is all except first field with : delimiter" {
    RET_VALUE='5'
    RET_RESULT="tralalalala lala lalala"
    TEST_STRING="${RET_VALUE}:${RET_RESULT}"
    run get_std_out "${TEST_STRING}"
    assert_success
    echo "${output}"
    [[ "${output}" == "${RET_RESULT}" ]]
    [[ "${status}" == 0 ]]
}
