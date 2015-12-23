#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Set default directories" {
    INSTANCE_DIR="/tmp"
    source ../share/avst-app/lib/common/startup.cfg.d/02default_dirs
    [[ "${INSTALL_DIR}" == "${INSTANCE_DIR}/install" ]]
    [[ "${HOME_DIR}" == "${INSTANCE_DIR}/home" ]]
}

