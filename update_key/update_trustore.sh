#!/bin/bash
source /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh

SUBSYSTEM_NAME=
CERT_NAME=
SERVICE_NAME=
FLAG=
TARGET_PATH=
TARGET_KEYSTORE=
SOURCE_KEYSTORE=
PASSWORD=
TARGET_PASSWORD=
ROOT_CA=
USER_CA=
HOST_NAME=

###############
# ERROR CODES #
###############
ERR_WRONG_OPTION=1


#############
# VARIABLES #
#############
SERVICES_NAME=("common_mediations" "q3user" "nbi3gcpm" "nbi3gc" "nbisnmp" "nwi3" "nx2s" "xoh" "generic_mediations" "ne3sws_dynamicadaptation" "saucnt" "nbine3s" "fmascii")
USERS_NAME=("esbadmin" "q3usr" "nbi3gcpm" "nbi3gc" "nbisnmp" "nwi3" "nx2suser" "xohuser" "genmdsrv" "dauser" "sauuser" "nbine3s" "asciifm")


##################################
## I/O functions
##

function printUsage() {
    echo -e "Usage: $0 -servicename <service_name> "
    echo -e "Options:"
    echo -e "\t-servicename \t service name"
    echo -e "\t-h \t Prints this message"
    echo "Exit codes:"
    echo "  0 - success"
    echo "  $ERR_WRONG_OPTION - wrong option"

}

##############
# VALIDATION #
##############
function parseArguments {
	while [ "$1" != "" ]; do
	    case $1 in
                -servicename )          shift
                                        SERVICE_NAME=$1
                                        ;;
	        -h | --help )           printUsage
	                                exit
	                                ;;
	        * )                     printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter $1 is not needed"
	                                exit $ERR_WRONG_OPTION
	    esac
	    shift
	done

}

function validateParameters {
    # Check mandatory parameters
    [ -z "$SERVICE_NAME" ] &&    					printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter -servicename is mandatory"
		TARGET_KEYSTORE="/var/opt/oss/certificates/${SERVICE_NAME}/truststore.jks"
		TARGET_PATH="/var/opt/oss/certificates/${SERVICE_NAME}"
                TARGET_PASSWORD="servicemix"
ROOT_CA="/var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem"
USER_CA="/var/opt/oss/certificates/adm/ca-cert/netact.user.ca.pem"
		if [ ! -f ${ROOT_CA} ]
                then
        	printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "${ROOT_CA} does not exists, please check root CA generated correctlly"
	        fi	
                if [ ! -f ${USER_CA} ]
                then
                printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "${USER_CA} does not exists, please check root CA generated correctlly"
                fi
    for i in "${!SERVICES_NAME[@]}";
    do
        if [ "${SERVICES_NAME[$i]}"x = "${SERVICE_NAME}"x ]; then
            USER_NAME=${USERS_NAME[$i]}
            break;
        fi
    done
    if [ -z "${USER_NAME}" ]; then
        printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter -servicenameu is not correct"
    fi

}

#############
# FUNCTIONS #
#############
# execute command, print output to debug log. Return execution status code.
# parameters:
#       $@: command and parameters
function apj_execute_without_exit_v2 () {
        APJ_LOG_PRINT=`echo $* | sed -e 's/storepass.*[[:space:]]/storepass ##### /g'`
        apj_note "executing: ${APJ_LOG_PRINT}"
        APJ_LOG_O=`eval $* 2>&1`
        APJ_LOG_RC=$?
        APJ_LOG_PRINT=`echo $* | sed -e 's/storepass.*[[:space:]]/storepass ##### /g'`
        apj_debug "$APJ_LOG_O"
        if [ "${APJ_LOG_RC}" -ne "0" ]
        then
                apj_error "${APJ_LOG_PRINT} exited with code ${APJ_LOG_RC}"
                return ${APJ_LOG_RC}
        else
                apj_note "${APJ_LOG_PRINT} exited with code ${APJ_LOG_RC}"
                return 0
        fi
}
# execute command, print output to debug log. Return execution status code.
# parameters:
#       $@: command and parameters
function apj_execute_v2 () {
        APJ_LOG_PRINT=`echo $* | sed -e 's/storepass.*[[:space:]]/storepass ##### /g'`
        apj_note "executing: ${APJ_LOG_PRINT}"
        APJ_LOG_O=`eval $* 2>&1`
        APJ_LOG_RC=$?
        if [ "${APJ_LOG_RC}" -ne "0" ]
        then
                apj_note "$APJ_LOG_O"
                apj_error "${APJ_LOG_PRINT} exited with code ${APJ_LOG_RC}"
                exit ${APJ_LOG_RC}
                #return ${APJ_LOG_RC}
        else
                apj_debug "$APJ_LOG_O"
                apj_note "${APJ_LOG_PRINT} exited with code ${APJ_LOG_RC}"
                return 0
        fi
}

function printUsageAndExitWithErrorCode {
    printUsage
    exitWithErrorCode $1 "$2"
}

function exitWithErrorCode {
    local err_code=$1
    local msg=$2
    echo -e "\n$0: ERROR:\t $msg"
    exit $err_code
}

function updateKeystore {
		if [ -f ${TARGET_KEYSTORE} ] 
		then
                    apj_execute_without_exit_v2 "keytool -delete -alias 'netactrootca' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                    apj_execute_without_exit_v2 "keytool -delete -alias 'netactuserca' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
	            apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                    apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactuserca' -file ${USER_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
		else
                    apj_execute_v2 "mkdir -p ${TARGET_PATH}"
                    apj_execute_v2 "chown -f ${USER_NAME}:sysop ${TARGET_PATH}"
                    apj_execute_v2 "chmod -f 750 ${TARGET_PATH}"
                    if [ -f {GLOBAL_KEYSTORE} ]       
                    then 
                        apj_execute_v2 "cp -fp ${GLOBAL_KEYSTORE} ${TARGET_KEYSTORE}"
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactuserca' -file ${USER_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                    else
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactuserca' -file ${USER_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "chown -f ${USER_NAME}:sysop ${TARGET_KEYSTORE}"
                        apj_execute_v2 "chmod -f 600 ${TARGET_KEYSTORE}"
                    fi
		fi
}

##################################
## Main
##
parseArguments $@
validateParameters

date_stamp=$(date +%Y-%m-%d)
apj_note "Logs could be found at: /var/opt/oss/log/install/NSN-jbi_cpf/NSN-jbi_cpf-installation_$date_stamp.log"
apj_note "executing: $0 $*"

updateKeystore

