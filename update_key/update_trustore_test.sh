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
CLIENT_CA=
HOST_NAME=

###############
# ERROR CODES #
###############
ERR_WRONG_OPTION=1


#############
# VARIABLES #
#############


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
CLIENT_CA="/var/opt/oss/certificates/adm/ca-cert/netact.client.ca.pem"
		if [ ! -f ${CLIENT_CA} ]
                then
        	printUsageAndExitWithErrorCode $ERR_WRONG_OPTION "${CLIENT_CA} does not exists, please check root CA generated correctlly"
	        fi	
}

#############
# FUNCTIONS #
#############
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
		if [ -f $TARGET_KEYSTORE  ] 
		then
                                apj_execute_without_exit "keytool -delete -alias 'netact client ca' -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
				apj_execute "keytool -import -v -trustcacerts -alias 'netact client ca' -file ${CLIENT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
		else
                                apj_execute "mkdir -p ${TARGET_PATH}"
				apj_execute "keytool -import -v -trustcacerts -alias 'netact client ca' -file ${CLIENT_CA} -keystore ${TARGET_KEYSTORE} -storepass ${TARGET_PASSWORD} -noprompt"
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

##updateKeystore

