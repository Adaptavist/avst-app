#!/usr/bin/env bats

load ../test_helper

setup() {
    # source functions to test
    source ../share/avst-app/lib/common/helpers.sh
}

@test "no version_comparison returns 0" {
while read -r test
do
    IFS=' ' read -a array <<< "$test"
    run version_comparison "${array[0]}" "${array[1]}" "${array[2]}"
    assert_success
done << EOF
1 = 1
2.1 < 2.2
3.0.4.10 > 3.0.4.2
4.08 < 4.08.01
3.2.1.9.8144 > 3.2
3.2 < 3.2.1.9.8144
1.2 < 2.1
2.1 > 1.2
5.6.7 = 5.6.7
1.01.1 = 1.1.1
1.1.1 = 1.01.1
1 = 1.0
1.0 = 1
1.0.2.0 = 1.0.2
1..0 = 1.0
1.0 = 1..0
EOF
}

@test "no version_comparison returns 1" {
while read -r line
do
    IFS=' ' read -a array <<< "$line"
    run version_comparison "${array[0]}" "${array[1]}" "${array[2]}"
    assert_fail
done << EOF
1 < 1
2.1 > 2.2
3.0.4.10 = 3.0.4.2
4.08 = 4.08.01
3.2.1.9.8144 < 3.2
3.2 > 3.2.1.9.8144
1.2 = 2.1
2.1 < 1.2
5.6.7 < 5.6.7
1.01.1 < 1.1.1
1.1.1 > 1.01.1
1 > 1.0
1.0 > 1
1.0.2.0 > 1.0.2
1..0 > 1.0
1.0 > 1..0
EOF
}


@test "test check_version to fail because of >" { 
    run check_versions "1.1" "1.0"
    assert_fail
}

@test "test check_version to fail because of =" { 
    run check_versions "1.1" "1.1"
    assert_fail
}

@test "test check_version to succeed" { 
    run check_versions "1.0" "1.1"
    assert_success
}

@test "test vercomp function to return 0 when versions are =" { 
    run vercomp "1.1" "1.1"
    [[ "$status" == 0 ]]
}

@test "test vercomp function to return 1 when versions are >" { 
    run vercomp "1.2" "1.1"
    [[ "$status" == 1 ]]
}

@test "test vercomp function to return 1 when versions are <" { 
    run vercomp "1.0" "1.1"
    [[ "$status" == 2 ]]
}
