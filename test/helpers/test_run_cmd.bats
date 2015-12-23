#!/usr/bin/env bats

load ../test_helper

setup() {
    # source functions to test
    source ../share/avst-app/lib/common/helpers.sh
}

@test "execute simple command" {
    TEST_STRING="tralalalala"
    run run_cmd echo "${TEST_STRING}"
    assert_success
    echo "${output}"
    [[ "${output}" == *"${TEST_STRING}"* ]]
    [[ "${status}" == 0 ]]
}

@test "execute simple command that fails to return error code as first value on stdout followed by :" {
    TEST_STRING="tralalalala"
    run run_cmd ls -l "${TEST_STRING}"
    assert_success
    echo "${output}"
    echo "${status}"
    # ls: cannot access tralalalala: No such file or directory return error code 2
    [[ "${output}" == $"2:ls: cannot access ${TEST_STRING}: No such file or directory"* ]]
    [[ "${output}" == *"Non-zero exit value whilst running \"ls -l ${TEST_STRING}\""* ]]
    [[ "${status}" == 0 ]]
}

modify_file () {
    TEST_FOLDER="/tmp/testing_run_cmd"
    echo "modified_file" > "${TEST_FOLDER}/test_file"
}

@test "execute simple command will modify file" {
    TEST_FOLDER="/tmp/testing_run_cmd"
    mkdir -p "${TEST_FOLDER}"
    echo "original" > "${TEST_FOLDER}/test_file"
    
    run run_cmd modify_file
    assert_success
    [[ $(cat "${TEST_FOLDER}/test_file") == "modified_file" ]]
    [[ "${status}" == 0 ]]
    rm -rf "${TEST_FOLDER}"
}

@test "execute simple command with mock option enabled will not modify file" {
    TEST_FOLDER="/tmp/testing_run_cmd"
    mkdir -p "${TEST_FOLDER}"
    echo "original" > "${TEST_FOLDER}/test_file"
    MOCK_CMD=echo
    run run_cmd modify_file
    assert_success
    echo "${output}"
    [[ "${output}" == *"modify_file"* ]]
    [[ "${status}" == 0 ]]
    [[ $(cat "${TEST_FOLDER}/test_file") == "original" ]]
    rm -rf "${TEST_FOLDER}"
}

@test "execute echo command with mock option enabled" {
    MOCK_CMD=echo
    run run_cmd echo modify_file
    assert_success
    echo "${output}"
    [[ "${output}" == $"0:echo modify_file" ]]
    [[ "${status}" == 0 ]]
}

@test "test run_cmd with mocked return status" {  
    MOCK_RETURN_STATUS=54
    MOCK_CMD=echo
    TEST_STRING="tralalala la"
    run run_cmd echo "${TEST_STRING}"
    assert_success
    echo "${output}"
    [[ "${output}" == "${MOCK_RETURN_STATUS}:echo ${TEST_STRING}" ]]
    [[ "${status}" == 0 ]]
}

@test "test run_cmd with mocked return status and value" {  
    MOCK_RETURN_STATUS=56
    MOCK_RETURN_VALUE="mocked std out"
    MOCK_CMD=echo
    TEST_STRING="tralalala la"
    run run_cmd echo "${TEST_STRING}"
    assert_success
    echo "${output}"
    [[ "${output}" == "${MOCK_RETURN_STATUS}:echo ${TEST_STRING}${MOCK_RETURN_VALUE}"* ]]
    [[ "${status}" == 0 ]]
}

@test "execute combined command that fails" {
    TEST_STRING="tralalalala"
    run run_cmd "service '${TEST_STRING}' status | grep running"
    assert_success
    echo "${output}"
    echo "${status}"
    # Unrecognized service: error 1
    [[ "${output}" == $"1:"*" unrecognized service"* ]]
    [[ "${output}" == *"Non-zero exit value whilst running"* ]]
    [[ "${status}" == 0 ]]
}
