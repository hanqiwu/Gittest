#!/bin/bash
source /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh

SUBSYSTEM_NAME=
CERT_NAME=
SERVICE_NAME=
USER_NAME=
FLAG=
TARGET_PATH=
TARGET_KEYSTORE=
SOURCE_KEYSTORE=
PASSWORD=
CERTSTATE=
TARGET_PASSWORD=
ROOT_CA=
ROOT_CA_PKCS=
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
    echo -e "Usage: $0 -ssname <subsystem_name> -certname <certification_name> -servicename <service_name> "
    echo -e "Options:"
    echo -e "\t-ssname \t subsystem name"
    echo -e "\t-certname \t certification name"
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
	        -ssname )               shift
	                                SUBSYSTEM_NAME=$1
	                                ;;
	        -certname )             shift
                                        CERT_NAME=$1
                                        ;;
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
    [ -z "$SUBSYSTEM_NAME" ] &&             printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter -ssname is mandatory"
    [ -z "$CERT_NAME" ] &&    					printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter -certname is mandatory"
    [ -z "$SERVICE_NAME" ] &&    					printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "Parameter -servicename is mandatory"
        GLOBAL_KEYSTORE="/d/oss/global/certificate/smx/${SERVICE_NAME}/keystore.jks"
	TARGET_KEYSTORE="/var/opt/oss/certificates/${SERVICE_NAME}/keystore.jks"
	TARGET_PATH="/var/opt/oss/certificates/${SERVICE_NAME}"
	SOURCE_KEYSTORE="/var/opt/oss/certificates/adm/${SUBSYSTEM_NAME}/${CERT_NAME}.jks"
        TARGET_PASSWORD="servicemix"
        ROOT_CA="/var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem"
        if [ ! -f ${SOURCE_KEYSTORE} ]
        then
       	printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "${SOURCE_KEYSTORE} does not exists, please check if Parameter -ssname ${SUBSYSTEM_NAME} and -certname are correct"
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

function getKeyStorePassword {
    PASSWORD=$(apj_execute_with_return "/var/opt/oss/local/cert-adm/bin/cert-adm-tool.sh get-password --ssname ${SUBSYSTEM_NAME} --certname ${CERT_NAME}")
}

function getCertStatus {
    CERTSTATE=$(apj_execute_with_return "/var/opt/oss/local/cert-adm/bin/cert-adm-tool.sh get-certificate-state --ssname ${SUBSYSTEM_NAME} --certname ${CERT_NAME}")
}

function updateKeystore {
		if [ -f ${TARGET_KEYSTORE}  ] 
		then
                    if [[ ${CERTSTATE} == "-1" ]] || [[ ${CERTSTATE} == "1" ]]
                    then
                        apj_execute_without_exit_v2 "keytool -delete -alias 'netactrootca' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_without_exit_v2 "keytool -delete -alias 'med_frw' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
		        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
		        apj_execute "keytool -importkeystore -alias ${CERT_NAME} -srckeystore ${SOURCE_KEYSTORE} -destkeystore ${TARGET_KEYSTORE} -srcstorepass \"${PASSWORD}\" -deststorepass ${TARGET_PASSWORD} -destalias med_frw -noprompt"
	            fi
		else
                    apj_execute_v2 "mkdir -p ${TARGET_PATH}"
                    apj_execute_v2 "chown -f ${USER_NAME}:sysop ${TARGET_PATH}"
                    apj_execute_v2 "chmod -f 750 ${TARGET_PATH}"

		    if [ -f ${GLOBAL_KEYSTORE} ]
                    then
                        apj_execute_v2 "cp -fp ${GLOBAL_KEYSTORE} ${TARGET_KEYSTORE}"                        
                        apj_execute_without_exit_v2 "keytool -delete -alias 'med_frw' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_without_exit_v2 "keytool -delete -alias 'netact client ca' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "keytool -importkeystore -alias ${CERT_NAME} -srckeystore ${SOURCE_KEYSTORE} -destkeystore ${TARGET_KEYSTORE} -srcstorepass \"${PASSWORD}\" -deststorepass ${TARGET_PASSWORD} -destalias med_frw -noprompt"
                    else
                        apj_execute_v2 "keytool -import -v -trustcacerts -alias 'netactrootca' -file ${ROOT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
                        apj_execute_v2 "keytool -importkeystore -alias ${CERT_NAME} -srckeystore ${SOURCE_KEYSTORE} -destkeystore ${TARGET_KEYSTORE} -srcstorepass \"${PASSWORD}\" -deststorepass ${TARGET_PASSWORD} -destalias med_frw -noprompt"
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

getCertStatus
getKeyStorePassword
updateKeystore

