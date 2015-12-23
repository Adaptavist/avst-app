#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "PARAMS must be present" {
    run source ../share/avst-app/lib/atlassian/install.d/03expand_tarball
    assert_fail
    [[ "${output}" == *"install/expand_tarball: tarball"* ]]
    [[ "${status}" == 20 ]]
}

@test "PARAMS must be present and identify file path" {
    PARAMS="blabla"
    run source ../share/avst-app/lib/atlassian/install.d/03expand_tarball
    assert_fail
    [[ "${output}" == *"install/expand_tarball: tarball"* ]]
    [[ "${status}" == 20 ]]
}

@test "runs tar with --strip components and changes ownership of expanded folder" {
    DEBUG=1
    FILENAME="testfile.tar.gz"
    touch $FILENAME
    PARAMS=$FILENAME
    INSTANCE_GROUP="group"
    INSTANCE_USER="user"
    INSTANCE_DIR="/tmp"
    MOCK_CMD="echo"
    run source ../share/avst-app/lib/atlassian/install.d/03expand_tarball
    assert_success
    echo "${output}"
    [[ "${output}" == *"tar -zxf ${FILENAME} --group=${INSTANCE_GROUP} --owner=${INSTANCE_USER} -C ${INSTANCE_DIR}/install --strip-components=1"* ]]
    [[ "${output}" == *"chown -R ${INSTANCE_USER}:${INSTANCE_GROUP} ${INSTANCE_DIR}/install"* ]]
    rm -f $FILENAME
}

