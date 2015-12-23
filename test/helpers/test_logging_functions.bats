#!/usr/bin/env bats

load ../test_helper

setup() {
    # source functions to test
    source ../share/avst-app/lib/common/helpers.sh
    TEST_OUTPUT="blabla"
    EMPTY_OUTPUT=""
}

@test "debug function off" {
    DEBUG=0
    run debug "${TEST_OUTPUT}"
    assert_success "${EMPTY_OUTPUT}"
}

@test "debug function on, prints blue text" {
    DEBUG=1
    run debug "${TEST_OUTPUT}"
    assert_success "${COL_BLUE:-}$TEST_OUTPUT${COL_RESET:-}"
}

@test "info function does not depend on DEBUG option" {
    DEBUG=0
    run info "${TEST_OUTPUT}"
    assert_success "${COL_GREEN:-}$TEST_OUTPUT${COL_RESET:-}"
}

@test "info function prints green text" {
    DEBUG=1
    run info "${TEST_OUTPUT}"
    assert_success "${COL_GREEN:-}$TEST_OUTPUT${COL_RESET:-}"
}

@test "warn function does not depend on DEBUG option" {
    DEBUG=0
    run warn "${TEST_OUTPUT}"
    assert_success "${COL_YELLOW:-}$TEST_OUTPUT${COL_RESET:-}"
}

@test "warn function prints yellow text" {
    DEBUG=1
    run warn "${TEST_OUTPUT}"
    assert_success "${COL_YELLOW:-}$TEST_OUTPUT${COL_RESET:-}"
}

@test "fatal function does not depend on DEBUG option" {
    DEBUG=0
    run fatal "${TEST_OUTPUT}"
    assert_success
}

@test "fatal function prints red text two times" {
    DEBUG=1
    run fatal "${TEST_OUTPUT}"
    assert_success
    OCCURENCE=`echo "${output}" | grep -o ${TEST_OUTPUT} | wc -l`
    [[ $OCCURENCE == 2 ]]
    [[ "${output}" == *"${COL_RED}"* ]]
}

@test "clean_log cleans global log" {
    VARIABLE="test"
    log_set_variable VARIABLE
    clean_log
    [[ "${GLOBAL_LOG}" == "" ]]
}

@test "global logging" {
    VARIABLE="test"
    log_set_variable VARIABLE
    echo "LOG:${GLOBAL_LOG}" 
    echo "EXP: VARIABLE '${VARIABLE}'"
    [[ "${GLOBAL_LOG}" == " VARIABLE '${VARIABLE}'" ]]
    clean_log
}

@test "global logging will not fail if variable does not exist, or should it?" {
    run log_set_variable VAR
    echo "LOG:${GLOBAL_LOG}"
    echo "EXP:$output"
    [[ "${GLOBAL_LOG}" == "" ]]
}

@test "global logging will fail if param is not passed" {
    run log_set_variable
    assert_fail
    echo "${GLOBAL_LOG}"
    echo "OUT:${output}"
    echo "EXP:"
    [[ "${output}" == *"common/helpers: Please provide variable name as parameter"* ]]
    [[ "${GLOBAL_LOG}" == "" ]]
}

@test "print log does not print if DEBUG is not set" {
    DEBUG=0
    VARIABLE="test"
    log_set_variable VARIABLE
    run print_log
    echo "${GLOBAL_LOG}"
    assert_success ""
}

@test "print_log prints variables if DEBUG is set" {
    DEBUG=1
    VARIABLE="test"
    log_set_variable VARIABLE
    VARIABLE2="test2"
    log_set_variable VARIABLE2
    run print_log
    assert_success
    [[ "${output}" == *"VARIABLE"* ]]
    [[ "${output}" == *"${VARIABLE}"* ]]
    [[ "${output}" == *"VARIABLE2"* ]]
    [[ "${output}" == *"${VARIABLE2}"* ]]
    [[ "${output}" == *"Variables are printed in the order they are applied, the last value counts."* ]]
}

