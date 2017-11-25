#!/usr/bin/env bash

# you need to modify the following file in <tomcat_home>/conf/context.xml do:
#
#<Context reloadable="true">
# <Resources allowLinking="true"> </Resources>

TOMCAT_HOME=/home/mhewedy/programs/apache-tomcat-8.5.23
WEB_APP_NAME=$(basename $(pwd))     # should be same as maven artifactId

CLEAN_BUILD_OPT="--clean-build"
DEPLOY_OPT="--deploy"

result=0

function copyClasses {
    echo "copy classes files"
    rm -rf ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}/WEB-INF/classes
    cp -rf $(pwd)/target/classes ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}/WEB-INF/
}

function usage {
    echo "usage: $(basename $0) ${CLEAN_BUILD_OPT}|${DEPLOY_OPT}"
}

case "$1" in
    ${CLEAN_BUILD_OPT})
        echo "Starting a Clean Build"
        mvn clean package

        echo "recreate ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}"
        rm -rf ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}
        mkdir -p ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}/WEB-INF

        echo "link webapp files"
        ln -sf $(pwd)/src/main/webapp/* ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}/

        echo "link all WEB-INF/* files except the classes"
        echo "$(pwd)/target/${WEB_APP_NAME}*/WEB-INF/*"
        ln -sf $(pwd)/target/${WEB_APP_NAME}*/WEB-INF/* ${TOMCAT_HOME}/webapps/${WEB_APP_NAME}/WEB-INF/

        copyClasses

        result=$?
        ;;
    ${DEPLOY_OPT})
        echo  "starting incremental re-deploy based on .class file change"
        echo "*** make sure that you have build the java source code before the deployment***"
        copyClasses

        result=$?
        ;;
    *)
        usage
        result=1
       ;;
esac

exit ${result}
