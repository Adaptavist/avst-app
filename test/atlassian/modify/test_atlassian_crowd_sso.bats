#!/usr/bin/env bats

load ../../test_helper

setup() {
    source ../share/avst-app/lib/common/helpers.sh
}

@test "by default ignore crowd sso" {
    DEBUG=1
    run source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    assert_success
    [[ "${output}" == *"Crowd SSO - IGNORED"* ]]
}

@test "disabled crowd sso for confluence sets ConfluenceAuthenticator in seraph-config file" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
    CROWD_SSO_ENABLE=0
    PRODUCT="confluence"
    source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    [[ "${NATIVE_AUTHENTICATOR}" == "com.atlassian.confluence.user.ConfluenceAuthenticator" ]]
    [[ $(grep "<authenticator class=\"com.atlassian.confluence.user.ConfluenceAuthenticator\"/>" "${SERAPH_CONFIG_FILE}") ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "disabled crowd sso for jira sets JiraSeraphAuthenticator in seraph-config file" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
    CROWD_SSO_ENABLE=0
    PRODUCT="jira"
    source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    [[ "${NATIVE_AUTHENTICATOR}" == "com.atlassian.jira.security.login.JiraSeraphAuthenticator" ]]
    [[ $(grep "<authenticator class=\"com.atlassian.jira.security.login.JiraSeraphAuthenticator\"/>" "${SERAPH_CONFIG_FILE}") ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso for jira sets SSOSeraphAuthenticator in seraph-config file and set up crowd.properties file when CROWD_APP_NAME CROWD_APP_PASSWORD CROWD_LOGIN_URL CROWD_SERVER_URL are set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_NAME="app_name"
    CROWD_APP_PASSWORD="passwd"
    CROWD_LOGIN_URL="login_url"
    CROWD_SERVER_URL="server_url"
    PRODUCT="jira"
    source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    [[ "${CROWD_SSO_AUTHENTICATOR}" == "com.atlassian.jira.security.login.SSOSeraphAuthenticator" ]]
    [[ $(grep "<authenticator class=\"com.atlassian.jira.security.login.SSOSeraphAuthenticator\"/>" "${SERAPH_CONFIG_FILE}") ]]
    [[ $(grep "application.name=${CROWD_APP_NAME}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "application.password=${CROWD_APP_PASSWORD}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "crowd.base.url=${CROWD_SERVER_URL}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "crowd.server.url=${CROWD_SERVER_URL}/services" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.isauthenticated=session.isauthenticated" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.tokenkey=session.tokenkey" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.validationinterval=2" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.lastvalidation=session.lastvalidation" "${CROWD_PROPERTIES_FILE}") ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso for confluence sets ConfluenceCrowdSSOAuthenticator in seraph-config file and set up crowd.properties file when CROWD_APP_NAME CROWD_APP_PASSWORD CROWD_LOGIN_URL CROWD_SERVER_URL are set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_NAME="app_name"
    CROWD_APP_PASSWORD="passwd"
    CROWD_LOGIN_URL="login_url"
    CROWD_SERVER_URL="server_url"
    PRODUCT="confluence"
    source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    [[ "${CROWD_SSO_AUTHENTICATOR}" == "com.atlassian.confluence.user.ConfluenceCrowdSSOAuthenticator" ]]
    [[ $(grep "<authenticator class=\"com.atlassian.confluence.user.ConfluenceCrowdSSOAuthenticator\"/>" "${SERAPH_CONFIG_FILE}") ]]
    [[ $(grep "application.name=${CROWD_APP_NAME}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "application.password=${CROWD_APP_PASSWORD}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "crowd.base.url=${CROWD_SERVER_URL}" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "crowd.server.url=${CROWD_SERVER_URL}/services" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.isauthenticated=session.isauthenticated" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.tokenkey=session.tokenkey" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.validationinterval=2" "${CROWD_PROPERTIES_FILE}") ]]
    [[ $(grep "session.lastvalidation=session.lastvalidation" "${CROWD_PROPERTIES_FILE}") ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso fails if CROWD_APP_NAME is not set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_PASSWORD="passwd"
    CROWD_LOGIN_URL="login_url"
    CROWD_SERVER_URL="server_url"
    PRODUCT="confluence"
    run source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    assert_fail
    [[ "${status}" == 51 ]]
    [[ "${output}" == *"mandatory variables are not set"* ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso fails if CROWD_APP_PASSWORD is not set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_NAME="app_name"
    CROWD_LOGIN_URL="login_url"
    CROWD_SERVER_URL="server_url"
    PRODUCT="confluence"
    run source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    assert_fail
    [[ "${status}" == 51 ]]
    [[ "${output}" == *"mandatory variables are not set"* ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso fails if CROWD_SERVER_URL is not set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_NAME="app_name"
    CROWD_APP_PASSWORD="passwd"
    CROWD_LOGIN_URL="login_url"
    PRODUCT="confluence"
    run source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    assert_fail
    [[ "${status}" == 51 ]]
    [[ "${output}" == *"mandatory variables are not set"* ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

@test "enabled crowd sso fails if PRODUCT is not set" { 
    DEBUG=1
    WEBAPP_DIR="/tmp"
    mkdir -p "${WEBAPP_DIR}/WEB-INF/classes/"
    SERAPH_CONFIG_FILE="${WEBAPP_DIR}/WEB-INF/classes/seraph-config.xml"
    CROWD_PROPERTIES_FILE="${WEBAPP_DIR}/WEB-INF/classes/crowd.properties"
    cat <<EOF > "${SERAPH_CONFIG_FILE}"
    <security-config>
    <authenticator class="default-auth-value"/>
    </security-config>
EOF
cat <<FILE > "${CROWD_PROPERTIES_FILE}"
# crowd properties file
FILE
    CROWD_SSO_ENABLE=1
    CROWD_APP_NAME="app_name"
    CROWD_APP_PASSWORD="passwd"
    CROWD_LOGIN_URL="login_url"
    CROWD_SERVER_URL="server_url"
    # PRODUCT="confluence"
    run source ../share/avst-app/lib/atlassian/modify.d/69app_crowd_sso
    assert_fail
    [[ "${status}" == 50 ]]
    [[ "${output}" == *"Attempted to set CROWD_SSO for PRODUCT"* ]]
    rm -fr "${WEBAPP_DIR}/WEB-INF"
}

