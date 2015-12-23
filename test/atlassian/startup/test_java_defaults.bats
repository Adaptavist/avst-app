#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "fails if no HOME_DIR provided" {
    run source ../share/avst-app/lib/atlassian/startup.cfg.d/28java_defaults
    assert_fail
    [[ "${status}" == 13 ]]
    [[ "${output}" == *"HOME_DIR not set"* ]]
}

@test "sets java defaults if HOME_DIR is provided" {
    HOME_DIR="/tmp"
    source ../share/avst-app/lib/atlassian/startup.cfg.d/28java_defaults
    [[ "${DEF_JAVA_CUSTOM_D_OPTIONS}" == *"-Djava.awt.headless=true"* ]]
    [[ "${DEF_JAVA_CUSTOM_D_OPTIONS}" == *"-Dfile.encoding=UTF-8"* ]]
    [[ "${DEF_JAVA_BEHAVIORAL_OPTIONS}" == *"-XX:+UseParallelGC"* ]]
    [[ "${DEF_JAVA_BEHAVIORAL_OPTIONS}" == *"-XX:+UseParallelOldGC"* ]]
    [[ "${DEF_JAVA_BEHAVIORAL_OPTIONS}" == *"-XX:+DisableExplicitGC"* ]]
    [[ "${DEF_JAVA_GC1_OPTIONS}" == "" ]]
    echo "${DEF_JAVA_PERFORMANCE_OPTIONS}"
    [[ "${DEF_JAVA_PERFORMANCE_OPTIONS}" == *"-XX:InitialTenuringThreshold=15"* ]]
    [[ "${DEF_JAVA_PERFORMANCE_OPTIONS}" == *"-XX:MaxTenuringThreshold=15"* ]]
    [[ "${DEF_JAVA_PERFORMANCE_OPTIONS}" == *"-XX:SurvivorRatio=2"* ]]
    [[ "${DEF_JAVA_PERFORMANCE_OPTIONS}" == *"-XX:NewRatio=2"* ]]
    [[ "${DEF_JAVA_DEBUGING_OPTIONS}" == *"-XX:+PrintGC"* ]]
    [[ "${DEF_JAVA_DEBUGING_OPTIONS}" == *"-XX:+PrintGCDetails"* ]]
    [[ "${DEF_JAVA_DEBUGING_OPTIONS}" == *"-XX:+PrintTenuringDistribution"* ]]
    [[ "${DEF_JAVA_DEBUGING_OPTIONS}" == *"-XX:+PrintGCDateStamps"* ]]
    [[ "${DEF_JAVA_DEBUGING_OPTIONS}" == *"-XX:+HeapDumpOnOutOfMemoryError"* ]]
}

