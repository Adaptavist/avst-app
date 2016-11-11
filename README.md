OS Packages for Adaptavist Application Manager (aka Avst-App)
=============================================================

## Intro

This repository contains two things:

* Scripts to build avst-app packages which can then be uploaded and installed from Adaptavist's package server.
* Scripts which are packaged into the various avst-app packages.

## Package Usage/Management

Documentation regarding the usage (setup/installation/management) of these packages can be [found here](https://i.adaptavist.com/display/MAMA/AVST-APP+documentation).

Some additional information regarding what directories are used can be found in: `share/avst-app/doc/README`

## Building Packages

It is only possible to build both deb and rpm packages using Ubuntu (tested on 14.04).

Prerequisites for building packages:

    sudo apt-get install ruby-dev git rpm
    sudo gem install fpm                   # Don't do this on any of our servers

To build the packages of Atlassian applications (using fpm), run:

    ./build.sh

To publish the packages of Atlassian applications to Nexus (using mvn), run:

    ./release.sh

## Writing Packages

Each available Atlassian product must have a directory within `share/avst-app/lib/product/`.

Three notible exceptions are:

* `bin/avst-app/`: this is the actual shell-script installed into `/usr/bin` for installation/management of Atlassian Applications
* `share/avst-app/lib/atlassian/`: the general Atlassian package, which handles common Atlassian Application installation/management tasks
* `share/avst-app/lib/tomcat/`: installation and setup of a Tomcat web server

There is also a `share/avst-app/lib/common/` directory containing scripts that are *always* run for the [avst-app commands](https://i.adaptavist.com/display/MAMA/AVST-APP+documentation#AVST-APPdocumentation-Usage).

Within the product-specific directory e.g. `share/avst-app/lib/product/fisheye/` there may be one or more directories with matching names to
those found in the `share/avst-app/lib/common/` directory.

Within those directories should be a number of shell-scripts performing whatever application-specific code is required for:

 * startup (this is run at the start of every command)
 * install (which is really just setup)
 * modify
 * install-service
 * start
 * upgrade
 * prepare
 * restore
 * destroy
 * regeneraterc

The naming of these shell-scripts determines the order in which they are run.

For each command given to avst-app, the list of scripts in `share/avst-app/lib/common/<command name>.d/` are combined with those in
the product specific directory (e.g. `share/avst-app/lib/product/jira/<command name>.d/`) and ordered using "natural ordering".

### Exit codes

The following exit/return codes are used (as of 2014-10-09):

* 01: INSTANCE_NAME not set
* 01: BASE_DIR not set
* 01: Missing Tomcat server.xml
* 10: Missing variable config in avst-app.cfg.sh
* 10: Failed prerequisites
* 10: Install directory already exists
* 11: Java isn't installed
* 11: Can't initialise git repo
* 12: Missing CROWD properties in config file
* 13: HOME_DIR not set
* 20: Missing tarball
* 20: Invalid Bamboo server URL specified
* 20: Missing Coverity installer
* 21: Can't find INSTALL_DIR/bin/installService.sh
* 21: Can't find PROVIDER_FILESYSTEM_DIR
* 21: Can't find database connection details
* 21: Missing artifactory license
* 23: Missing Crowd SSO config file
* 23: Invalid version
* 32: Tarball extraction failed
* 32: JAR extraction failed
* 32: CROWD Wizard not passed
* 32: Missing .version file
* 32: Missing params from avst-app.cfg.sh
* 33: Missing .state file
* 34: Can't upgrade application if not installed/modified
* 36: Unsupported OS
* 38: Search service template not found in INSTALL_DIR
* 45: Can't stop service
* 46: Can't start service
* 50: Can't set CROWD_SSO for unsupported product
* 51: Missing mandatory variables for CROWD

## Setup JNDI source

Make sure variables are set:
* JNDI_SOURCE_NAME
* JNDI_SOURCE_USERNAME
* JNDI_SOURCE_PASSWORD
* JNDI_SOURCE_URL

For more details and defaults check lib/tomcat/modify.d/39set_session_timout and lib/tomcat/modify.d/40tomcat_set_vars

## Changing database setup

Setting up database and credentials can be done by setting DB_SETUP_DB=1. For all available options per application check 70setup_db scripts


