#!/bin/bash

# Use this script to start a standalone Synchrony process on Linux (for use with Confluence Data Center only)
# Replace the <values> below with appropriate values for your environment.
# For more information about the Synchrony system properties you can configure see:
# https://confluence.atlassian.com/display/DOC/Configuring+Synchrony+for+Data+Center

# Parse the Synchrony home folder from the script location
SYNCHRONY_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

################################## Parameters to configure ##################################

# IP address or hostname of this Synchrony node -- should be reachable by other nodes
SERVER_IP="<SERVER_IP>"

# Your Confluence database information (can be copied from confluence.cfg.xml in your Confluence home directory)
DATABASE_URL="<YOUR_DATABASE_URL>"
DATABASE_USER="<DB_USERNAME>"

# We recommend setting your password with the environment variable SYNCHRONY_DATABASE_PASSWORD.
# This allows Synchrony to detect sensitive information without making it visible in the process command information.
# However, you may also hardcode your password here.
DATABASE_PASSWORD="<DB_PASSWORD>"

# # Uncomment this section if you want to do node discovery using TCP/IP
# # Comma separated list of IP addresses for each cluster node
# TCPIP_MEMBERS="<TCPIP_MEMBERS>"
# CLUSTER_JOIN_PROPERTIES="\
# -Dcluster.join.type=tcpip \
# -Dcluster.join.tcpip.members=${TCPIP_MEMBERS}"

# # Uncomment this section if you want to do node discovery in AWS
# ATL_HAZELCAST_NETWORK_AWS_TAG_KEY="<AWS_TAG_KEY>"
# ATL_HAZELCAST_NETWORK_AWS_TAG_VALUE="<AWS_TAG_VALUE>"
# CLUSTER_JOIN_PROPERTIES="\
# -Dcluster.join.type=aws \
# -Dcluster.join.aws.tag.key=${ATL_HAZELCAST_NETWORK_AWS_TAG_KEY} \
# -Dcluster.join.aws.tag.value=${ATL_HAZELCAST_NETWORK_AWS_TAG_VALUE}"

# # Uncomment this section if you want to do node discovery using multicast
# CLUSTER_JOIN_PROPERTIES="\
# -Dcluster.join.type=multicast"

# Locations of the synchrony-standalone.jar and database driver jar
DATABASE_DRIVER_PATH="<JDBC_DRIVER_PATH>"
SYNCHRONY_JAR_PATH="<PATH_TO_SYNCHRONY_STANDALONE_JAR>"

# URL that the browser uses to contact Synchrony -- should include the context path
SYNCHRONY_URL="<SYNCHRONY_URL>"

# Optionally override default system property values here. Consult docs for more optional properties
# Example usage: OPTIONAL_OVERRIDES="-Dsynchrony.port=8099 -Dcluster.listen.port=5701"
OPTIONAL_OVERRIDES=""

# # Uncomment this section if you're running Confluence in an IPv6 environment
# OPTIONAL_OVERRIDES="${OPTIONAL_OVERRIDES} -Dhazelcast.prefer.ipv4.stack=false"

# # Uncomment this section to specify an executable shell script to source for environment variables
# # Useful for passing sensitive information (i.e. passwords) to Synchrony
# # Use this method when setting environment variables for Synchrony running as a service
# # Example of file contents:
# #	 	export SYNCHRONY_DATABASE_USERNAME="<DB_USERNAME>"
# #		export SYNCHRONY_DATABASE_PASSWORD="<DB_PASSWORD>"
# SYNCHRONY_ENV_FILE="<PATH_TO_ENV_FILE>"

# Path to file where Synchrony PID will be stored
# If you change this, you'll also need to set this value in 'stop-synchrony.sh'
SYNCHRONY_PID_FILE="${SYNCHRONY_HOME}/synchrony.pid"

# Optionally configure JVM
JAVA_BIN="java"
JAVA_OPTS="-Xss2048k -Xmx2g"

#############################################################################################

# check for help prompt or if user has tried to run the script without editing it
if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "${CLUSTER_JOIN_PROPERTIES}" ]; then
    echo "Edit this file to provide Synchrony information on how to run."
	echo "Then simply run 'start-synchrony.sh' or 'start-synchrony.sh -fg' (to run the process in the foreground)"
	echo "For more information about configuring Synchrony, visit https://confluence.atlassian.com/display/DOC/Configuring+Synchrony+for+Data+Center"
	exit
fi

# don't try to start Synchrony if another process is already running
if [ ! -z "${SYNCHRONY_PID_FILE}" ] && [ -f "${SYNCHRONY_PID_FILE}" ]; then
	if [ -s "${SYNCHRONY_PID_FILE}" ] && [ -r "${SYNCHRONY_PID_FILE}" ]; then
		PID=`cat ${SYNCHRONY_PID_FILE}`
		if [ ! -z "${PID}" ]; then
			ps -p ${PID} > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				echo "Synchrony appears to still be running with PID ${PID}. Start aborted."
				echo "If the following process is not a Synchrony process, remove ${SYNCHRONY_PID_FILE} and try again."
				ps -f -p $PID
				exit 1
			fi
		fi
	fi

	echo "Please remove ${SYNCHRONY_PID_FILE} and try to start Synchrony again."
	exit 1
fi

# try to source env file if it exists
if [ -f "${SYNCHRONY_ENV_FILE}" ]; then
	if [ -x "${SYNCHRONY_ENV_FILE}" ]; then
		source ${SYNCHRONY_ENV_FILE}
	else
		echo "Synchrony environment file ${SYNCHRONY_ENV_FILE} exists, but isn't executable."
		echo "If you want to set Synchrony properties this way, stop Synchrony and adjust the file format accordingly."
	fi
fi

_RUNJAVA="${JAVA_BIN} ${JAVA_OPTS}"
SYNCHRONY_OPTS="-classpath ${SYNCHRONY_JAR_PATH}:${DATABASE_DRIVER_PATH}"
SYNCHRONY_OPTS="${SYNCHRONY_OPTS} -Dsynchrony.service.url=${SYNCHRONY_URL}"
SYNCHRONY_OPTS="${SYNCHRONY_OPTS} -Dsynchrony.bind=${SERVER_IP}"
SYNCHRONY_OPTS="${SYNCHRONY_OPTS} ${CLUSTER_JOIN_PROPERTIES}"
SYNCHRONY_OPTS="${SYNCHRONY_OPTS} ${OPTIONAL_OVERRIDES}"

[ -z "${SYNCHRONY_DATABASE_URL}" ] && SYNCHRONY_OPTS="${SYNCHRONY_OPTS} -Dsynchrony.database.url=${DATABASE_URL}"
[ -z "${SYNCHRONY_DATABASE_USERNAME}" ] && SYNCHRONY_OPTS="${SYNCHRONY_OPTS} -Dsynchrony.database.username=${DATABASE_USER}"
[ -z "${SYNCHRONY_DATABASE_PASSWORD}" ] && SYNCHRONY_OPTS="${SYNCHRONY_OPTS} -Dsynchrony.database.password=${DATABASE_PASSWORD}"

if [[ ${@} == *"-fg"* ]]; then
	${_RUNJAVA} ${SYNCHRONY_OPTS} synchrony.core sql
else
	echo "To run Synchrony in the foreground, start the server with start-synchrony.sh -fg"
	${_RUNJAVA} ${SYNCHRONY_OPTS} synchrony.core sql > /dev/null 2>&1 &

	# Getting the PID of the process
	PID=$!
	echo $PID > $SYNCHRONY_PID_FILE
	echo "Starting Synchrony with PID ${PID}..."
	echo "Binding: ${SERVER_IP}"
	echo "Please wait 30 seconds, then check this heartbeat URL in your browser for an 'OK': ${SYNCHRONY_URL}/heartbeat"
fi
