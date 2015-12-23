#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "java prerequisite test, must contain HotSpot" {
    MOCK_CMD='echo HotSpot'
    run source ../share/avst-app/lib/atlassian/install.d/01check_prerequisites
    assert_success
}

@test "java prerequisite test, must contain HotSpot, fails in case java HotSpot is not present" {
    MOCK_CMD='echo "Another java"'
    run source ../share/avst-app/lib/atlassian/install.d/01check_prerequisites
    assert_fail
    [[ "${output}" == *"Please install an Oracle JDK (not OpenJDK)"* ]]
    [[ "${status}" == 11 ]]
}

