#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "State file must exist" {
    INSTANCE_DIR="asdgafgwrtbv5trwascdxe"
    run source ../share/avst-app/lib/common/upgrade.d/50check_prerequisites
    assert_fail
    [[ "${status}" == 33 ]]
    [[ "${output}" == *"Can not find .state file"* ]]
}

@test "State must be supported. Installed, modified or upgrading" {
    INSTANCE_DIR="/tmp/test_stuff"
    mkdir -p "${INSTANCE_DIR}"
    echo "not_supported_state" > "${INSTANCE_DIR}/.state"
    run source ../share/avst-app/lib/common/upgrade.d/50check_prerequisites
    assert_fail
    [[ "${status}" == 34 ]]
    [[ "${output}" == *"Can not make upgrade of application if state is not installed or modified."* ]]
    rm -rf "${INSTANCE_DIR}"
}

@test "TARBALL must be passed as param" {
    INSTANCE_DIR="/tmp/test_stuff"
    mkdir -p "${INSTANCE_DIR}"
    echo "installed" > "${INSTANCE_DIR}/.state"
    run source ../share/avst-app/lib/common/upgrade.d/50check_prerequisites
    assert_fail
    [[ "${status}" == 20 ]]
    [[ "${output}" == *"tarball \"\" does not exist"* ]]
    rm -rf "${INSTANCE_DIR}"
}

@test "Passes for state = installed and existing tarball" {
    INSTANCE_DIR="/tmp/test_stuff"
    mkdir -p "${INSTANCE_DIR}"
    PARAMS="${INSTANCE_DIR}/tarball_file"
    touch "${PARAMS}"
    for i in "installed" "modified" "upgrading"; do
        echo "${i}" > "${INSTANCE_DIR}/.state"
        run source ../share/avst-app/lib/common/upgrade.d/50check_prerequisites
        assert_success
    done
    rm -rf "${INSTANCE_DIR}"
}
