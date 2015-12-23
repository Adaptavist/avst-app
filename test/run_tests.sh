#!/usr/bin/env bash

# pass all .bats files from all subdirs of test to bats
bats `find . -iname *.bats`

