#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Version file must exist to perform upgrade" {
    INSTANCE_DIR="/tmp/not_existing_folder_to_test_stuff123412341"
    run source ../share/avst-app/lib/common/upgrade.d/70backup_original
    assert_fail
    [[ "${status}" == 32 ]]
    [[ "${output}" == *"File .version does not exist"* ]]
}

@test "Moves all files to instal_<old_version> and home_<old_version>" {
    INSTANCE_DIR="/tmp/test_upgrade"
    INSTALL_DIR="${INSTANCE_DIR}/install"
    HOME_DIR="${INSTANCE_DIR}/home"
    mkdir -p "${INSTANCE_DIR}" "${INSTALL_DIR}" "${HOME_DIR}"
    echo "install content" > "${INSTALL_DIR}/install_file"
    echo "home content" > "${HOME_DIR}/home_file"
    VER="1.2.3"
    echo "${VER}" > "${INSTANCE_DIR}/.version"

    run source ../share/avst-app/lib/common/upgrade.d/70backup_original
    assert_success
    [[ -d "${INSTALL_DIR}_${VER}" ]]
    [[ $(grep "install content" "${INSTALL_DIR}_${VER}/install_file") ]]
    [[ -d "${HOME_DIR}_${VER}" ]]
    [[ $(grep "home content" "${HOME_DIR}_${VER}/home_file") ]]

    rm -rf "${INSTANCE_DIR}"
}

@test "Removes content of old backups if exists and moves new files to instal_<old_version> and home_<old_version>" {
    INSTANCE_DIR="/tmp/test_upgrade"
    INSTALL_DIR="${INSTANCE_DIR}/install"
    HOME_DIR="${INSTANCE_DIR}/home"
    VER="1.2.3"
    mkdir -p "${INSTANCE_DIR}" "${INSTALL_DIR}" "${HOME_DIR}" "${INSTALL_DIR}_${VER}" "${HOME_DIR}_${VER}"
    echo "install content" > "${INSTALL_DIR}/install_file"
    echo "home content" > "${HOME_DIR}/home_file"
    echo "old install content" > "${INSTALL_DIR}_${VER}/install_file"
    echo "old home content" > "${HOME_DIR}_${VER}/home_file"

    echo "${VER}" > "${INSTANCE_DIR}/.version"

    run source ../share/avst-app/lib/common/upgrade.d/70backup_original
    assert_success
    [[ -d "${INSTALL_DIR}_${VER}" ]]
    [[ $(grep "install content" "${INSTALL_DIR}_${VER}/install_file") ]]
    [[ -d "${HOME_DIR}_${VER}" ]]
    [[ $(grep "home content" "${HOME_DIR}_${VER}/home_file") ]]

    rm -rf "${INSTANCE_DIR}"
}