#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "test if version is provided in wrong format" { 
    VERSION="3.a"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    assert_fail
    echo "${status}"
    echo "${output}"
    [[ "${status}" == 23 ]]
    [[ "${output}" == *"Can not determine new version or it is not in the right format"* ]]

}

@test "test if version is provided in correct format, .version is created with its content" { 
    VERSION="3.1"
    INSTANCE_DIR="/tmp/test12341234"
    mkdir -p "${INSTANCE_DIR}"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VERSION ${INSTANCE_DIR}/.version) ]]
    rm "${INSTANCE_DIR}/.version"
}

@test "test if unsupported product is passed, warning is shown" { 
    PRODUCT="tmp"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ "${output}" == *"Unsupported application. Please provide version manually"* ]]
}

@test "test if product is confluence, version is parsed and set" { 
    PRODUCT="confluence"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    WEBAPP_DIR="${INSTANCE_DIR}/web"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/lib"
    VER="7.9.1"
    touch "${WEBAPP_DIR}/WEB-INF/lib/confluence-${VER}.jar"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

@test "test if product is jira, version is parsed and set" { 
    PRODUCT="jira"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    WEBAPP_DIR="${INSTANCE_DIR}/web"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/lib"
    VER="7.9.1"
    touch "${WEBAPP_DIR}/WEB-INF/lib/jira-api-${VER}.jar"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

@test "test if product is bamboo, version is parsed and set" { 
    PRODUCT="bamboo"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    WEBAPP_DIR="${INSTANCE_DIR}/web"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/lib"
    VER="7.4.1"
    touch "${WEBAPP_DIR}/WEB-INF/lib/atlassian-bamboo-api-${VER}.jar"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

@test "test if product is stash, version is parsed and set" { 
    PRODUCT="stash"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    WEBAPP_DIR="${INSTANCE_DIR}/web"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/lib"
    VER="6.9.1"
    touch "${WEBAPP_DIR}/WEB-INF/lib/stash-api-${VER}.jar"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}


@test "test if product is crowd, version is parsed and set" { 
    PRODUCT="crowd"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    WEBAPP_DIR="${INSTANCE_DIR}/web"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/lib"
    VER="7.9"
    touch "${WEBAPP_DIR}/WEB-INF/lib/crowd-api-${VER}.jar"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

@test "test if product is fisheye, version is parsed and set" { 
    PRODUCT="fisheye"
    INSTANCE_DIR="/tmp/dafvsdfv1341234"
    INSTALL_DIR="${INSTANCE_DIR}/install"
    mkdir -p "${INSTALL_DIR}"
    VER="7.8.1"
    echo "<title>FishEye ${VER}</title>" > "${INSTALL_DIR}/README.html"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

@test "test if product is fisheye, version is parsed and set, and path contains more -" { 
    PRODUCT="fisheye"
    INSTANCE_DIR="/tmp/dafv-sdfv13-41234"
    INSTALL_DIR="${INSTANCE_DIR}/install"
    mkdir -p "${INSTALL_DIR}"
    VER="7.8.1"
    echo "<title>FishEye ${VER}</title>" > "${INSTALL_DIR}/README.html"
    run source ../share/avst-app/lib/common/prepare.d/89autodetect_version
    echo "${status}"
    echo "${output}"
    assert_success
    [[ "${status}" == 0 ]]
    [[ $(grep $VER ${INSTANCE_DIR}/.version) ]]
    rm -rf "${INSTANCE_DIR}" 
}

