#!/usr/bin/env bats

load ../test_helper

setup() {
    # source functions to test
    source ../share/avst-app/lib/common/helpers.sh
}

@test "parses version correctly" {
    VER="3.1"
    EXTENSION=".tar.gz"
    FILE="somepath/somefile-${VER}${EXTENSION}"
    run parse_version "${FILE}" "${EXTENSION}"
    assert_success
    echo "${output}"
    [[ "${output}" == "${VER}" ]]
    [[ "${status}" == 0 ]]
}
