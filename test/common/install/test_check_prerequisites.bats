#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Instance user must exist" {
    INSTANCE_USER="asdgafgwrtbv5trwascdxe"
    run source ../share/avst-app/lib/common/install.d/01check_prerequisites
    assert_fail
    [[ "${status}" == 10 ]]
    [[ "${output}" == *"User ${INSTANCE_USER} does not exist"* ]]
}

@test "Instance group must exist" {
    INSTANCE_GROUP="nieqrnifbcqndijcdao"
    run source ../share/avst-app/lib/common/install.d/01check_prerequisites
    assert_fail
    [[ "${status}" == 10 ]]
    [[ "${output}" == *"Group ${INSTANCE_GROUP} does not exist"* ]]
}

@test "Instance dir must exist" {
    INSTANCE_DIR="somewhateverdirectorythathassmallchancetoexist"
    run source ../share/avst-app/lib/common/install.d/01check_prerequisites
    assert_fail
    [[ "${status}" == 10 ]]
    echo "${output}"
    [[ "${output}" == *"INSTANCE_DIR: \"${INSTANCE_DIR}\" does not exist"* ]]
}

