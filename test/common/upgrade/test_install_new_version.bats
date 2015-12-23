#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "mark state as upgrading, runs avst-app install and modify, moves content of home backup to new home folder" {
    DEBUG=1
    INSTANCE_DIR="/tmp/upgrade_test_folder1234123"
    HOME_DIR="${INSTANCE_DIR}/home"
    OLD_VERSION="1.2.4"
    INSTANCE_NAME="testing_stuff"
    TARBALL="tarbal.tar.gz"
    mkdir -p "${INSTANCE_DIR}" "${HOME_DIR}" "${HOME_DIR}_${OLD_VERSION}"
    CONTENT="content of backed-up file"
    echo "${CONTENT}" > "${HOME_DIR}_${OLD_VERSION}/file_in_backup"
    MOCK_CMD='echo'

    run source ../share/avst-app/lib/common/upgrade.d/80install_new_version
    assert_success
    echo "${output}"
    echo "${status}"
    [[ "${output}" == *"avst-app --debug ${INSTANCE_NAME} install ${TARBALL}"* ]]
    [[ "${output}" == *"avst-app --debug ${INSTANCE_NAME} modify"* ]]
    [[ $(grep $CONTENT ${HOME_DIR}/file_in_backup) ]]
    rm -fr "${INSTANCE_DIR}"
}
