#!/bin/bash

# Use this script to stop a standalone Synchrony process on Linux (for use with Confluence Data Center only)
# Replace the <values> below with appropriate values for your environment.
# For more information about the Synchrony system properties you can configure see:
# https://confluence.atlassian.com/display/DOC/Configuring+Synchrony+for+Data+Center

# Parse the Synchrony home folder from the script location
SYNCHRONY_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ################################# Parameters to configure ##################################

# Path to file where Synchrony PID will be stored, as set in 'start-synchrony.sh'
# Only change this if you've changed the value in 'start-synchrony.sh'
SYNCHRONY_PID_FILE="${SYNCHRONY_HOME}/synchrony.pid"

# #############################################################################################

if [ ! -f "${SYNCHRONY_PID_FILE}" ]; then
    echo "Unable to locate Synchrony PID file!"
    exit 1
fi

PID=`cat ${SYNCHRONY_PID_FILE}`
if [ -z "${PID}" ]; then
    echo "Synchrony PID file exists, but no PID was found. Aborting!"
else
    process=`ps -fp ${PID} | grep synchrony.core`
    if [ -z "${process}" ]; then
        echo "Unable to find Synchrony process with corresponding PID. Aborting!"
    else
        SLEEP=5
        while [ $SLEEP -ge 0 ]; do
            kill ${PID} >/dev/null 2>&1
            if [ $? -gt 0 ]; then
                rm -f "${SYNCHRONY_PID_FILE}" >/dev/null 2>&1
                if [ $? != 0 ]; then
                    echo "The PID file could not be removed or cleared."
                fi
                echo "Synchrony process with pid ${PID} stopped."
                break
            fi

            if [ $SLEEP -gt 0 ]; then
                sleep 1
            fi

            if [ $SLEEP -eq 0 ]; then
                echo "Synchrony process did not stop in time. Attempting to signal the process to stop through OS signal."
                rm -f "${SYNCHRONY_PID}" >/dev/null 2>&1
                kill -9 ${PID} >/dev/null 2>&1
            fi
            SLEEP=`expr ${SLEEP} - 1 `
        done
    fi
fi