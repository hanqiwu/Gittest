#!/bin/sh
# apj debug log helper functions for shell scripts.
#
# Info, warning and error messages goes to stdout, debug log 
# and temp log.
# Debug messages goes to debug log and temp log, which can be 
# dumped to stdout or stderr when error occures.

# 2008-10-29 12:00:10 node1 [NOTE] executing: foo --bar=zoo

#APJ_LOG_DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

#DATE_FORMAT="+%b %d %T"
#HOSTNAME=`hostname -s |cut -c1-10`

#HL=`echo -n $HOSTNAME|wc -c`
#let APJ_LOG_HL2=8
#let APJ_LOG_HL2=28


APJ_LOG_PWD="+SDfe32Fbbyy66" # just some random string

trap 'trap_retval=$?; rm -f "${APJ_LOG_TMP_DEBUG_FILE}" ; exit ${trap_retval}' INT TERM EXIT

# temp log file. Contains all log messages printed with this instance
# , can be dumped to stdout(stderr) with apj_dump_log(_to_stderr) command 
# in case of error.
APJ_LOG_TMP_DEBUG_FILE=`mktemp -t temp.XXXXXXXXXX`|| exit 1

APJ_LOG_ERROR_DUMP=1

APJ_LOG_DIR=/var/opt/oss/log/install/NSN-jbi_cpf
if [ ! -e ${APJ_LOG_DIR} ]
then
	/bin/mkdir -p ${APJ_LOG_DIR}
	/bin/chown -h omc:sysop ${APJ_LOG_DIR}
	/bin/chmod 775 ${APJ_LOG_DIR}

fi

#time_stamp=$(date +%Y-%h-%dT%T)
date_stamp=$(date +%Y-%m-%d)
APJ_LOG_LOGFILE=/var/opt/oss/log/install/NSN-jbi_cpf/NSN-jbi_cpf-installation_$date_stamp".log"

apj_set_censored_word () {
	APJ_LOG_PWD=$@
}

apj_disable_dump () {
#	apj_debug "Disabling log dumping."
	APJ_LOG_ERROR_DUMP=0
}
apj_enable_dump () {
#	apj_debug "Enabling log dumping."
	APJ_LOG_ERROR_DUMP=1
}

apj_set_logfile_rights () {
	APJ_LOG_I=`id -u`

	if [ ! -e ${APJ_LOG_LOGFILE} ] 
	then
		touch ${APJ_LOG_LOGFILE}
		chown -h omc:sysop ${APJ_LOG_LOGFILE}
		chmod 660 ${APJ_LOG_LOGFILE}
	fi
	chmod 660 ${APJ_LOG_DIR}/NSN-jbi_cpf-installation_*.log

}



apj_print_stdout () {
	if [ "${APJ_SILENT}x" == "x" ]
	then
	  if [ "$1c" != "NOTEc" ]
	  then
		  echo -n "[$1] "
	  fi
	  shift
	  APJ_LOG_out=$@
	  if [ ! -z "${APJ_LOG_PWD}" ]
	  then
		  for APJ_LOG_a in ${APJ_LOG_PWD} 
		  do
			  APJ_LOG_arg=`echo "${APJ_LOG_a}" | sed 's:[]\[\^\$\.\*\/]:\\\\&:g'`
			  APJ_LOG_out=`echo "${APJ_LOG_out}"|sed 's/'"$APJ_LOG_arg"'/########/g'`
		  done
	  fi
	  echo ${APJ_LOG_out}
	fi
}

apj_print_log () {
	# usage: log LEVEL "message"
	# where level is free text. 
	# example: log NOTE "installing foo to bar"
	if [ "${APJ_SILENT}x" == "x" ]
	then
	  APJ_LOG_arg=`echo "${APJ_LOG_PWD}" | sed 's:[]\[\^\$\.\*\/]:\\\\&:g'`
	  APJ_LOG_a=$1
	  APJ_LOG_i=0
  #	APJ_LOG_DT=`date "$APJ_LOG_DATE_FORMAT"`
	  APJ_LOG_DT=""
	  shift

	  if [ ! -z "$*" ]
	  then
		  APJ_LOG_o=$*
		  if [ ! -z "${APJ_LOG_PWD}" ]
		  then
			  for APJ_LOG_b in ${APJ_LOG_PWD} 
			  do
				  APJ_LOG_arg=`echo "${APJ_LOG_b}" | sed 's:[]\[\^\$\.\*\/]:\\\\&:g'`
				  APJ_LOG_o=`echo "${APJ_LOG_o}"|sed 's/'"$APJ_LOG_arg"'/########/g'`
			  done
		  fi
		  # save output so we can print it at once
		  APJ_LOG_OUT=`echo "${APJ_LOG_o}" |while read -r APJ_LOG_line
		  do
			  
			  echo "${APJ_LOG_line}" >>${APJ_LOG_TMP_DEBUG_FILE}
  #			[ $APJ_LOG_i -gt 0 ] && (printf -- "%-${APJ_LOG_HL2}s%s" "" ; echo "$APJ_LOG_line") || (printf -- "%-15s %-7s %s" "${APJ_LOG_DT}" "[${APJ_LOG_a}]" ; echo "${APJ_LOG_line} ")
			  [ $APJ_LOG_i -gt 0 ] && (printf -- "%-${APJ_LOG_HL2}s%s" "" ; echo "$APJ_LOG_line") || (printf -- "%-7s %s" "[${APJ_LOG_a}]" ; echo "${APJ_LOG_line} ")
			  ((APJ_LOG_i++))
		  done`
  		echo "${APJ_LOG_OUT}" >>${APJ_LOG_LOGFILE}

	  fi
	fi
}

# set name and rights of debug log.
# rights can only be set if called as a root.
# parameters:
# 	$1: full path to debug log
#
apj_set_logfile () {
	echo "apj_set_logfile is not in use anymore."
#	APJ_LOG_LOGFILE=$1
#	apj_set_logfile_rights
}


# prints [NOTE] message to debug log and to stdout.
# parameters:
# 	$@: message
# 	
apj_note () {
	time_stamp=$(date +%Y-%h-%dT%T)
	apj_print_stdout "PID:$$ | PPID:$PPID " "$time_stamp" " | NOTE | " "$@"
	apj_print_log "PID:$$ | PPID:$PPID " "$time_stamp" " | NOTE | " "$@"
}

# prints [DEBUG] message to debug log.
# parameters:
# 	$@: message
# 	
apj_debug () {
	time_stamp=$(date +%Y-%h-%dT%T)
	apj_print_log "PID:$$ | PPID:$PPID " "$time_stamp" " | DEBUG | " "$@"
}

# prints [WARN] message to debug log and to stdout.
# parameters:
# 	$@: message
# 	
apj_warning () {
	time_stamp=$(date +%Y-%h-%dT%T)
	apj_print_stdout "PID:$$ | PPID:$PPID " "$time_stamp" " | WARN | " "$@"
	apj_print_log "PID:$$ | PPID:$PPID " "$time_stamp" " | WARN | " "$@"
}

# prints [ERROR] message to debug log and to stdout.
# parameters:
# 	$@: message
# 	
apj_error () {
	time_stamp=$(date +%Y-%h-%dT%T)
	apj_print_stdout "PID:$$ | PPID:$PPID " "$time_stamp" " | ERROR | " "$@"
	apj_print_log "PID:$$ | PPID:$PPID " "$time_stamp" " | ERROR | " "$@"
}

# prints content of temp log to stdout.
# parameters:
# 	$1: prefix to add to all lines [optional]
apj_dump_log () {
	if [ "${APJ_LOG_ERROR_DUMP}" -eq "1" ]
	then
		if [ "${1}c" == "c" ]
		then
			while read APJ_LOG_line
			do
				echo "${APJ_LOG_line}"
			done < ${APJ_LOG_TMP_DEBUG_FILE}
		else
			while read APJ_LOG_line
			do
				echo "${1}" "${APJ_LOG_line}"
			done < ${APJ_LOG_TMP_DEBUG_FILE}
		fi
	fi 
}

# prints content of temp log to stderr.
# parameters:
# 	$1: prefix to add to all lines [optional]
apj_dump_log_to_stderr () {
	apj_dump_log $@ 1>&2
}

# execute command, print output to debug log. Return execution status code.
# parameters:
# 	$@: command and parameters
apj_execute () {
	apj_note "executing: $*"
	APJ_LOG_O=`eval $* 2>&1`
	APJ_LOG_RC=$?	
	if [ "${APJ_LOG_RC}" -ne "0" ]
	then
		apj_note "$APJ_LOG_O"
		apj_error "$* exited with code ${APJ_LOG_RC}"
		exit ${APJ_LOG_RC}
		#return ${APJ_LOG_RC}
	else
		apj_debug "$APJ_LOG_O"
		apj_note "$* exited with code ${APJ_LOG_RC}"
		return 0
	fi
}

# execute command, print output to debug log. Return execution status code.
# parameters:
# 	$@: command and parameters
apj_execute_without_exit () {
	apj_note "executing: $*"
	APJ_LOG_O=`eval $* 2>&1`
	APJ_LOG_RC=$?
	apj_debug "$APJ_LOG_O"
	if [ "${APJ_LOG_RC}" -ne "0" ]
	then
		apj_error "$* exited with code ${APJ_LOG_RC}"
		return ${APJ_LOG_RC}
	else
		apj_note "$* exited with code ${APJ_LOG_RC}"
		return 0
	fi
}

# execute command, print output to debug log. Return execution output on success, execution status code on failure
# parameters:
# 	$@: command and parameters
apj_execute_with_return () {
	apj_debug "executing: $*"
	APJ_LOG_O=`eval $* 2>&1`
	APJ_LOG_RC=$?
	if [ "${APJ_LOG_RC}" -ne "0" ]
	then
		apj_note "$APJ_LOG_O"
		apj_error "$* exited with code ${APJ_LOG_RC}"
		exit ${APJ_LOG_RC}
		#return "${APJ_LOG_RC}"
	else
		apj_debug "$APJ_LOG_O"
		apj_debug "$* exited with code ${APJ_LOG_RC}"
		echo "${APJ_LOG_O}"
	fi
}


# execute command. Return execution status code.
# parameters:
# 	$@: command and parameters
apj_execute_script () {
	apj_note "executing: $*"
	APJ_LOG_O=`eval $* 2>&1`
	APJ_LOG_RC=$?
	if [ "${APJ_LOG_RC}" -ne "0" ]
	then
		apj_note "$APJ_LOG_O"
		apj_error "$* exited with code ${APJ_LOG_RC}"
		exit ${APJ_LOG_RC}
		#return ${APJ_LOG_RC}
	else
		apj_debug "$APJ_LOG_O"
		apj_note "$* exited with code ${APJ_LOG_RC}"
		return 0
	fi
}

apj_set_logfile_rights

