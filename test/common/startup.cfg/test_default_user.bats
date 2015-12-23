#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Set default user to hosting" {
    source ../share/avst-app/lib/common/startup.cfg.d/01default_user
    echo "${INSTANCE_USER}"
    [[ "${INSTANCE_USER}" == "hosting" ]]
    [[ "${INSTANCE_GROUP}" == "hosting" ]]
}

