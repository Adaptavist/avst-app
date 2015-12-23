#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "Set PRODUCT to lowercase" {
    PRODUCT="PrOdUcT"
    source ../share/avst-app/lib/common/startup.cfg.d/01product
    [[ "${PRODUCT}" == "product" ]]
}

