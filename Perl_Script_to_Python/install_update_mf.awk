
#!/usr/bin/awk -f
BEGIN {

	DEBUG = 1
	debug_file_location = "/var/opt/oss/log/install/NSN-jbi_cpf"
    log_dir_location = "/var/opt/oss/log/"
	jbi_cpf_reference_dir = "/opt/oss/NSN-jbi_cpf"
	mf_swp_reference_dir = "/opt/oss/NSN-mf_swp"
	jbi_swp_reference_dir = "/opt/oss/NSN-jbi_swp"
	apj_execute_file = "/opt/oss/NSN-jbi_cpf/jbi_logger/apj_execute.sh"
	
	#MF component list which contain mandatory and ignore component list. If file is mentioned as "ignore" then 
	#Even it is specified in instance configuration file it will not be considered during instance creation and if it is "mandatory" then
	#even if it is not specified in instance configuration file till will consider that file during instance creation
	
	mf_component_file = jbi_cpf_reference_dir "/conf/MFComponentList.txt"
	dca_variable_file = jbi_cpf_reference_dir "/conf/DCA_Variables.txt"
	env_variable_file = "/etc/profile.d/NSN-jbi_cpf.sh"
	
	COPY_NO_UPDATE = "copy_no_update"
	COPY_UPDATE = "copy_update"
	COPY_RESTORE_UPDATE = "copy_restore_update"
	OBSOLETE = "obsolete"
	LINK = "link"	
	
# Loop added for setting up the home directory

		if( "DIR" == check_isDirectory("/opt/oss/NSN-mf_swp/smx_standby") ) {
        	mf_swp_reference_home = "/opt/oss/NSN-mf_swp/smx_standby/"}
		else
			{mf_swp_reference_home = "/opt/oss/NSN-mf_swp/smx/"
		}
		if( "DIR" == check_isDirectory("/opt/oss/NSN-mf_swp/conf_standby") ) {
        	mf_swp_conf_dir = "/opt/oss/NSN-mf_swp/conf_standby/"}
		else
			{mf_swp_conf_dir = "/opt/oss/NSN-mf_swp/conf/"
		}
		
		
	
	if ( ( mode == "install" ) || ( mode == "upgrade" ) ) {
				
	    multicast_address = ""
		# read instance config file. This has to be first as this will read mandatory parameters
		read_instance_config(config_file)
		
		# read DCA variable list file
		read_instance_config(dca_variable_file)
		
		#Checking for all Mandatory parameter existence
		validate()
		backup_folder = "/var/opt/oss/log/NSN-jbi_cpf/back_up/"service_name
		commandForbackup_folder = "sh " apj_execute_file " apj_note " backup_folder ": is the backup_folder"
				system(commandForbackup_folder)
				
		
		tmp_dir = "/var/tmp/instance/"service_name
		commandForTempDir = "sh " apj_execute_file " apj_note " tmp_dir ": is the tmp_dir"
				system(commandForTempDir)
				
		# check whether instance already exists
	
		if( "DIR" == check_isDirectory(instance_dir"/smx") && "DIR" == check_isDirectory(instance_dir"/smx_standby")) {
			commandForSmxStandbyDir = "sh " apj_execute_file " apj_note " instance_dir"/smx_standby exists in "instance_dir".. starting upgrade"
			system(commandForSmxStandbyDir)}
		if( "DIR" == check_isDirectory(instance_dir"/smx") && "NOT_DIR" == check_isDirectory(instance_dir"/smx_standby")) {
			commandForLog = "sh " apj_execute_file " apj_note " "copying smx folder to standby folder in "instance_dir" and starting upgrade"
			system(commandForLog)
			commandForCopy = "cp -RPp "instance_dir"/smx " instance_dir"/smx_standby"
			executeSystemCommand(commandForCopy)}
		else{
			commandForLog = "sh " apj_execute_file " apj_note " "Instance not exists in  "instance_dir" start installation to create instance"
			system(commandForLog)}
		
				
		# Creating backup directory in debug_file_location
	        command = "/usr/bin/install -d --mode=755 --group=sysop --owner=omc " debug_file_location "/backup"
		executeSystemCommand(command)
		
		# compile script to install/upgrade instance
		script_file = jbi_cpf_reference_dir "/bin/" mode "_" service_name "_" "script.sh"
		printf "#!bin/sh\n" > script_file
		printf "source /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh\n" > script_file
		if ( null != instance_user_id && instance_user_id != 0 && "omc" != instance_user )	
		{
			create_ldap_user()			
		}
		loops=0	 
		while ( loops != 300 )
		{
			command = "id " instance_user
			if(0 != system(command)){
				print system("sleep 1")
			}else{
				commandForUserEntry = "sh " apj_execute_file " apj_note " instance_user " User reflected in shell after " loops "loops"
				system(commandForUserEntry)
				break;
			}
			loops=((loops+1))
		}
		if (loops == 300){
			commandForUserExit = "sh " apj_execute_file " apj_note " instance_user " User is not reflected even after 300 loops... Exiting awk script"
			system(commandForUserExit)
		    exit 127
		}
	}
	
	if ( mode == "install" ) {

		# check whether instance already exists
		printf "\nif [ -d %s ]\
		\nthen\
		\necho \" ================== %s Instance already exists / Configuration file not available ==================\" >> %s 2>&1\
		\necho \" ================== %s Instance already exists / Configuration file not available ==================\"\
		\napj_note \" ================== %s Instance already exists / Configuration file not available ==================\"\
		\nfi\n",instance_dir"/smx_standby", instance_dir, debug_file, instance_dir, instance_dir  > script_file	

		# creating the required folder
		create_remove_folder(FOLDERCREATE)

		# compile copies and link for instance
		for ( i in CONFIG ) {
			
			#the below script checks if the component is listed in MFComponentList.txt as REMOVED:<component_name> and then removes
			###### B E   C A R E F U L while using 'command | getline filename' should not be used more than once in the same flow 
			######   with same input i.e. '_reference'
			
			_reference_ = i
			command = "basename " _reference_
			command | getline filename
			command = "grep -w " filename " " jbi_cpf_reference_dir"/conf/MFComponentList.txt | grep -w REMOVED" 
			if(!system(command)){
				printf "WARN: The specified component %s is removed from MF hence ignoring\n",_reference_
				printf "WARN: The specified component %s is removed from MF hence ignoring\n",_reference_ > debug_file				
			}else{
				if ( ( CONFIG[i] == COPY_NO_UPDATE ) || ( CONFIG[i] == COPY_UPDATE ) || ( CONFIG[i] == COPY_RESTORE_UPDATE ) ) {
					copy_file(i, CONFIG[i], filename)

				}else if ( ( CONFIG[i] == LINK )) {
					file_link(i, CONFIG[i])

				}
			}
			
		}
        
		# Installation starts from here
		printf "\necho \"Installation directory used is %s and service name is %s \"\n",instance_dir,service_name >  script_file
		CPF_INSTALLATION_HOME=instance_dir"/smx"
		CPF_INSTALLATION_STANDBY_HOME=instance_dir"/smx_standby"
		
				
		# creating start/stop/status handling for instance
		printf"cat %s/bin/service.sh | sed \"12i\\JBI_EXECUTABLE=%s/bin/servicemix\"  |\
		sed \"12i\\JBI_HOME=%s\" | sed \"12i\\JBI_CONTAINER=%s\" |\
		sed \"12i\\PROGRAM=%s\" | sed 's:MF.pid:%s.pid:g' | sed 's:DB_SCHEMA:%s:' > %s/bin/%s\n",jbi_cpf_reference_dir,CPF_INSTALLATION_HOME,CPF_INSTALLATION_HOME,service_name,service_name,service_name,service_name,CPF_INSTALLATION_STANDBY_HOME,service_name > script_file
		
		printf "\nsed -i -e 's:JBI_USER_NAME:'\"%s\"':ig' %s/bin/%s\n",toupper(service_name)"_USER_NAME",CPF_INSTALLATION_STANDBY_HOME,service_name > script_file
		
		printf"\necho \"Changing ENV Variables to %s -- START\"\n",instance_dir > script_file

		
		printf"for file in $(grep -r -l \"MF_HOME\" %s)\
		\ndo\
		\nsed -i -e 's:$MF_HOME/mf-smx:'\"%s\"':ig' $file\
		\nsed -i -e 's:$MF_HOME/logs-installation:'\"%s/logs-installation\"':ig' $file\
		\nsed -i -e 's:$MF_HOME:'\"%s\"':ig' $file\
		\nsed -i -e 's:JBI_USER_NAME:'\"%s\"':ig' $file\
		\ndone\n",instance_dir,CPF_INSTALLATION_HOME,instance_dir,instance_dir, toupper(service_name)"_USER_NAME" > script_file

		printf"echo \"Changing ENV Variables to %s -- END\"\n",instance_dir > script_file

		

		command = "hostname"
		command | getline HOST_NAME
				
		printf "\napj_execute /bin/ln -sf %s/bin/%s /etc/init.d/%s >> %s 2>&1\n",CPF_INSTALLATION_HOME,service_name,service_name,debug_file > script_file
		printf "\napj_execute /bin/chown -h %s:sysop /etc/init.d/%s >> %s 2>&1\n",instance_user,service_name,debug_file > script_file
	
		printf "\napj_execute /bin/ln -sf /etc/init.d/%s /etc/init.d/%s-%s >> %s 2>&1\n",service_name,service_name,HOST_NAME,debug_file > script_file
		printf "\napj_execute /bin/chown -h %s:sysop /etc/init.d/%s-%s >> %s 2>&1\n",instance_user,service_name,HOST_NAME,debug_file > script_file
		
		printf "apj_execute dos2unix %s/bin/%s >> %s 2>&1\n",CPF_INSTALLATION_STANDBY_HOME,service_name,debug_file > script_file


		
	
		# Giving the permission to instance specific log folder
		printf "\napj_execute /bin/chown -R %s:sysop %s/* >> /dev/null\n",instance_user,"/var/opt/oss/log/"service_name > script_file
		printf "\napj_execute /bin/chmod 750 %s >> /dev/null\n", "/var/opt/oss/log/"service_name > script_file
		
		# Giving the permission to instance home folder
		#Relaxing permissions for FileDC
		printf "\napj_execute /bin/chmod 770 %s >> /dev/null\n", instance_dir > script_file
		
		printf "\napj_execute /bin/chown -R -h %s:sysop %s/smx_standby/* >> %s 2>&1\n",instance_user,instance_dir,debug_file > script_file

		printf "\necho \"Instance: %s in dir: %s installed\"\n",service_name, instance_dir > script_file
		printf "\necho \"Instance: %s in dir: %s installed\" >> %s \n",service_name, instance_dir,debug_file > script_file 
		
	}

	
	if ( mode == "upgrade" ) 
	{
		
		# check whether instance already exists
		printf "\nif [ -d %s ]\
		\nthen\
		\necho \" ================== %s exists checking for standby folder ==================\"\
			\nif [ -d %s ]\
				\nthen\
				\necho \" ================== standby folder exists in  %s starting upgrade ==================\"\
			\nfi\
		\nelse\
		\necho \" ================== Instance not exists in  %s start installation to create instance ==================\"\
		\napj_error \" ================== Instance not exists in  %s start installation to create instance ==================\"\
		\nexit 128\
		\nfi\n", instance_dir"/smx",instance_dir"/smx",instance_dir"/smx_standby", instance_dir,instance_dir, instance_dir > script_file	
		
		# creating/removing the folder
		create_remove_folder(FOLDERCREATE)
		
		# compile copies and 
		for ( i in CONFIG ) 
		{
			#the below command checks if the component is listed in MFComponentList.txt as REMOVED:<component_name> 
			#if found it will removes the component both at reference and instance side
			###### B E   C A R E F U L while using 'command | getline filename' should not be used more than once in the same flow 
			######   with same input i.e. '_reference'
			
			_reference_ = i
			command = "basename " _reference_
			command | getline filename
			command = "grep -w " filename " " jbi_cpf_reference_dir"/conf/MFComponentList.txt | grep -w REMOVED" 
			if(!system(command)){
				delete_file(i, CONFIG[i])
				printf "rm -rf %s\n", i > script_file
			}else{
				if ( ( CONFIG[i] == COPY_NO_UPDATE ) || ( CONFIG[i] == COPY_UPDATE ) || ( CONFIG[i] == COPY_RESTORE_UPDATE ) ) {
					copy_file(i, CONFIG[i], filename)

				}else if ( ( CONFIG[i] == OBSOLETE )) {
					delete_file(i, CONFIG[i])

				}else if ( ( CONFIG[i] == LINK )) {
					file_link(i, CONFIG[i])

				}
			}			

		}
        
       
		CPF_INSTALLATION_HOME=instance_dir"/smx"
		CPF_INSTALLATION_STANDBY_HOME=instance_dir"/smx_standby"
		
		# creating start/stop/status handling for instance
		printf"\ncat %s/bin/service.sh | sed \"12i\\JBI_EXECUTABLE=%s/bin/servicemix\"  |\
		sed \"12i\\JBI_HOME=%s\" | sed \"12i\\JBI_CONTAINER=%s\" |\
		sed \"12i\\PROGRAM=%s\" | sed 's:MF.pid:%s.pid:g' | sed 's:DB_SCHEMA:%s:'  >| %s/bin/%s\n",jbi_cpf_reference_dir,CPF_INSTALLATION_HOME,CPF_INSTALLATION_HOME,service_name,service_name,service_name,service_name,CPF_INSTALLATION_STANDBY_HOME,service_name > script_file
		
		printf "\nsed -i -e 's:JBI_USER_NAME:'\"%s\"':ig' %s/bin/%s\n",toupper(service_name)"_USER_NAME",CPF_INSTALLATION_STANDBY_HOME,service_name > script_file
		
		printf"for file in $(grep -r -l \"MF_HOME\" %s)\
		\ndo\
		\nsed -i -e 's:$MF_HOME/mf-smx:'\"%s\"':ig' $file\
		\nsed -i -e 's:$MF_HOME/logs-installation:'\"%s/logs-installation\"':ig' $file\
		\nsed -i -e 's:$MF_HOME:'\"%s\"':ig' $file\
		\nsed -i -e 's:JBI_USER_NAME:'\"%s\"':ig' $file\
		\ndone\n",instance_dir,CPF_INSTALLATION_HOME,instance_dir,instance_dir, toupper(service_name)"_USER_NAME" > script_file

	}	

	# This will be executed at the last
	if ( ( mode == "install" ) || ( mode == "upgrade" ) ) {

		updateSystemENV()

		# The directory created for Mediation logs.currently used by GEP 
		if( "NOT_DIR" == check_isDirectory("/var/opt/oss/log/install/" service_name) ) {
        	   command = "/usr/bin/install -d --mode=750 --group=sysop --owner=" instance_user " " "/var/opt/oss/log/install/" service_name
        	   executeSystemCommand(command)
		}
		
		# The directory created for audit log
		if( "NOT_DIR" == check_isDirectory(log_dir_location "/audit") ) {
         	   command = "/usr/bin/install -d --mode=770 --group=sysop --owner=" instance_user " " log_dir_location "/audit"
         	   executeSystemCommand(command)
		 }
		 
		# Create directory for selfmon config XML
		printf "\napj_note \"Creating directory for selfmon config XML\"\n" > script_file
		printf "\nif [[ ! -d %s && -d %s ]]\
				\nthen\
					\napj_note \" ================== copying conf folder to standby folder in %s and starting upgrade ==================\"\
					\napj_execute cp -RPp %s %s\
				\nelse\
					\napj_note \" ================== conf_standby folder exists in  %s starting upgrade ==================\"\
				\nfi\n", instance_dir"/conf_standby", instance_dir"/conf", instance_dir, instance_dir"/conf", instance_dir"/conf_standby", instance_dir > script_file
		printf " apj_execute \"/bin/mkdir -p %s/conf_standby/SelfMonComponents\"\n", instance_dir > script_file
		printf " apj_execute \"/bin/find %s/conf_standby -type d | xargs -r /bin/chown %s:sysop \"\n", instance_dir, instance_user  > script_file
		printf " apj_execute \"/bin/find %s/conf_standby -type d | xargs -r /bin/chmod 750 \"\n", instance_dir  > script_file

		# Create directory for SA Autorecovery CSV
		printf "\napj_note \"Creating directory for SA Autorecovery\"\n" > script_file
		printf " apj_execute \"/bin/mkdir -p %s/conf_standby/AutoRecovery\"\n", instance_dir > script_file
		printf " apj_execute \"/bin/find %s/conf_standby/AutoRecovery -type d | xargs -r /bin/chown %s:sysop \"\n", instance_dir, instance_user  > script_file
		printf " apj_execute \"/bin/find %s/conf_standby/AutoRecovery -type d | xargs -r /bin/chmod 750 \"\n", instance_dir  > script_file
		printf " apj_execute /usr/bin/install -d --mode=770 --group=sysop --owner=omc  /var/tmp/NSN-jbi_cpf/\n" > script_file
		printf " apj_execute /usr/bin/install -d --mode=770 --group=sysop --owner=omc  /var/tmp/NSN-jbi_cpf/AutoRecovery\n" > script_file

		# LDAP configuration
		# PR-122129ESPE02 MF forks a shell script from the SCA library.
		# copy the LDIF template and properties file from MF dir mf_swp_reference_dir/conf to instance specific dir instance_dir/smx/conf
		printf "\necho \"PR-122129ESPE02 corrections IN \" >> %s\n", debug_file > script_file
		#printf "if [[ -f %s/bin/wasusr.ldif.template && -d %s/smx/mf-conf ]]; then /bin/cp -f %s/bin/wasusr.ldif.template %s/smx/mf-conf/wasusr.ldif.template ; fi                  \n", jbi_cpf_reference_dir,instance_dir ,jbi_cpf_reference_dir,instance_dir >> script_file
		printf "if [[ -f %s/mf-conf/was-cred.properties && -d %s/smx_standby/mf-conf ]]; then /bin/cp -f %s/mf-conf/was-cred.properties %s/smx_standby/mf-conf/was-cred.properties ; fi                  \n", mf_swp_reference_home,instance_dir ,mf_swp_reference_home,instance_dir >> script_file
		 
		#create_service_link() #Commenting for fixing the regression for Pronto TC-5 
		# Playing safe
		printf "\napj_execute dos2unix %s/smx_standby/bin/*  >> /dev/null \n ", instance_dir >> script_file
		# Give instance_user:sysop ownership and 700 permissions to files of type directory
		printf "apj_execute \"find %s/smx_standby/ -type d | xargs -r /bin/chown %s:sysop \"\n", instance_dir, instance_user  >> script_file  		
		#Relaxing permissions for FileDC
		printf "apj_execute \"find %s/smx_standby/ -type d | xargs -r /bin/chmod 770 \"\n", instance_dir >> script_file
		# Give instance_user:sysop ownership for all files of type file
		# At the same time don't touch the files in hotdeploy directory.
		# They will be either links or brought by the respective user of the servicemix.
		# So it's their responsibility to protect the files brought by them 
		printf "apj_execute \"find %s/smx_standby/ -type f | grep -v hotdeploy | xargs -r /bin/chown %s:sysop \"\n", instance_dir,instance_user >> script_file  		
		# Give 400 permissions for files not in bin directory
		# At the same time don't touch the files in hotdeploy directory.
		# They will be either links or brought by the respective user of the servicemix.
		# So it's their responsibility to protect the files brought by them 
		#change file permission  of file except data and hotdeploy 
		printf "apj_execute \"find %s/smx_standby/ -type f | grep /bin/ | xargs -r /bin/chmod 700 \"\n", instance_dir >> script_file
		printf "apj_execute \"find %s/smx_standby/ -type f | grep /mf-conf/ | xargs -r /bin/chmod 660 \"\n", instance_dir >> script_file
		printf "apj_execute \"find %s/smx_standby/ -type f | grep /conf/ | xargs -r /bin/chmod 660 \"\n", instance_dir >> script_file
		
        # according to RTE guideline, the file permission should the least permission for certificate files
		printf "apj_execute \"find %s/smx_standby/conf/ -type f -name '*.jks' | xargs -r /bin/chmod 600 \"\n", instance_dir >> script_file
        # /opt/oss/NSN-mf_swp/smx/conf/keystore.jks, according to RTE guideline, the file permission should the least permission for certificate files
        printf "apj_execute \"find %s/conf/ -type f -name '*.jks' | xargs -r /bin/chmod 600 \"\n", mf_swp_reference_home >> script_file
		
		# Give 500 permissions for files in bin directory 
		printf "apj_execute \"find %s/smx_standby/ -type f -name '*.sh' |  xargs -r /bin/chmod 500 \"\n", instance_dir >> script_file
		# Change the ownership of the linked files to instance_user
		printf "apj_execute \"find %s/smx_standby/ -type l |xargs -r /bin/chown -R -h %s:sysop \"\n", instance_dir, instance_user >> script_file

		# Change the permission of xsd folder for instance user
                # PR 61468ESPE03: NetAct Base 6 to Netact Base 7 upgrade: Many different errors seen in the dca logs during the execution of create_update_jbi_instance.sh
                # GEP does not create xsd folder so the below check is added to eliminate errors in dca logs
		# Relaxing permissions for FileDC

		printf "if [ -d %s/smx_standby/conf/xsd ]; then chmod 770 %s/smx_standby/conf/xsd; fi \n",instance_dir,instance_dir >> script_file
		
		# Change the permission of SMX folder for instance user workaround till 19 aug
		#printf "apj_execute chmod -R 777 %s/smx/* \n", instance_dir >> script_file
		
	
		# Softlink creation for mf-oes-db.properties in each instance mf-conf folder		
		# PR 61468ESPE03: NetAct Base 6 to Netact Base 7 upgrade: Many different errors seen in the dca logs during the execution of create_update_jbi_instance.sh
		# GEP does not have mf-conf folder so the below check is added to eliminate errors in dca logs
		#Not required to create the softlink. the file is copied to the instance dir.
		printf "if [[ -f %s/mf-oes-db.properties && -d %s/smx_standby/mf-conf ]]; then /bin/ln -f -s %s/conf/mf-oes-db.properties %s/smx_standby/mf-conf/mf-oes-db.properties ; fi                  \n", mf_swp_conf_dir,instance_dir ,mf_swp_reference_dir,instance_dir >> script_file
		
		printf "if [[ -f %s/system-user-password.properties && -d %s/smx_standby/mf-conf ]]; then /bin/ln -f -s %s/conf/system-user-password.properties %s/smx_standby/mf-conf/system-user-password.properties ; fi                  \n", mf_swp_conf_dir,instance_dir ,mf_swp_reference_dir,instance_dir >> script_file
		
		#Fix for PR:86019ESPE03 ( Copying logrotate config file for mediation instances to /etc/logrotate.d/ )
        printf "if [[ -f /etc/logrotate.d/%s_logrotate ]]; then rm -f /etc/logrotate.d/%s_logrotate; fi     \n",service_name, service_name >> script_file
        printf "if [[ -f /etc/logrotate.d/%s_autorecovery_logrotate ]]; then rm -f /etc/logrotate.d/%s_autorecovery_logrotate; fi     \n", service_name, service_name >> script_file

        printf "echo -e \"create 0644 %s sysop\n/var/opt/oss/log/%s/Servicemix-Log/*.log{\nrotate 5\nsize   1024k\nmissingok\n}\" >> /etc/logrotate.d/%s_logrotate ; apj_execute chmod 644 /etc/logrotate.d/%s_logrotate ; \n",instance_user,service_name,service_name,service_name >> script_file

        printf "echo -e \"create 0644 %s sysop\n/var/opt/oss/log/%s/AutoRecovery-Log/*.log{\nrotate 5\nsize   1024k\nmissingok\n}\" >> /etc/logrotate.d/%s_autorecovery_logrotate ; apj_execute chmod 644 /etc/logrotate.d/%s_autorecovery_logrotate; \n",instance_user,service_name,service_name,service_name >> script_file


		printf "source ~/.bash_profile\n"> script_file		
		printf "\necho \"========================== %s Script Execution ENDS ===================================\" >> %s\n",mode, debug_file > script_file
		printf "\napj_execute rm -rf %s\n",tmp_dir > script_file
		close(script_file)

		
		
		command = "/bin/chmod +x " script_file
		executeSystemCommand(command)
		
		printf "============================= Script Generation for %s ENDS at %s==================================\n",mode,strftime() > debug_file
		printf "\n========================== %s Script Execution Starts ===================================\n",mode > debug_file
		
		# execute script. This will return 0 if script execution is successful
		command = "sh " script_file
		script_ret_val = executeSystemScript(command)
		if ( instance_user != "smxuser" )	
		{
	        update_prop_file = jbi_cpf_reference_dir"/bin/update_was_cred.sh"
                command = "sh " update_prop_file " " service_name
                printf " %s \n" , command > debug_file
			executeSystemScript(command)
			
			#Adding users to subscribe for Password Change Notification
			add_user_file = mf_swp_reference_home"/passwordchange/bin/add_user_details.sh"
			if( "EXISTS" == check_fileExists(add_user_file) )
			{	
			command = "sh " mf_swp_reference_home "/passwordchange/bin/add_user_details.sh " instance_user " appserv " service_name " appserv"
			executeSystemScript(command)
			}else{
				commandForUserAdd = "sh " apj_execute_file " apj_note " mf_swp_reference_home "/passwordchange/bin/add_user_details.sh is not available"
				system(commandForUserAdd)		
			}
		}
			
		#Added the configure_jbi_logging.sh to call automatically after instance creation
		command = "sh " jbi_swp_reference_dir"/bin/configure_jbi_logging.sh  " service_name
		executeSystemScript(command)
		
		#Executing update_backup_url script to update URL while creating/updating instance

		update_backup_url_script = jbi_cpf_reference_dir "/bin/update_backup_url.sh" 
		command = "sh " update_backup_url_script " " instance_dir
		executeSystemScript(command)
		
		#Moving the install/upgrade script to backup folder
		command = "/bin/mkdir -p " backup_folder
		executeSystemCommand(command)
		
		command = "mv --backup=numbered " script_file " " backup_folder
		executeSystemCommand(command)
		
		command = "/bin/chmod -R 640  " backup_folder
		executeSystemCommand(command)
		command = "/bin/chown -R omc:sysop " backup_folder
		executeSystemCommand(command)
			
		#This will create the Mediation DB
		if( ("true" == externalDB) && ( mode == "install" ) )
		{
			#dbSchema_file = 
		} 
		
		#This to create the instance specific certificate directory.
		command= "sh /opt/oss/NSN-jbi_cpf/bin/create_certificate_dir.sh " service_name " " instance_user " " instance_dir
		executeSystemScript(command)
		
		#Running the persistence script to update the property files
		if( ("true" == externalDB) && (  ( 0 == script_ret_val &&  mode == "install" )  ||   mode == "upgrade"  ) )
		{
			#Here we need to pass the IP address as argument to persistence script
			persistence_file = instance_dir "/smx_standby/mf-persistance/mf_persistance_install.sh"
			if( "EXISTS" == check_fileExists(persistence_file) )
			{	
			command = "sh " persistence_file  " -dss " DSS_IP " -app1 " AS1_IP " -inst " service_name " -vip " DSS_VIR_IP
			executeSystemScript(command)

				
			}else{
				printf "WARNING: The persistence script is missing and externalDB option is enabled. Data persistence is not enabled\n" > debug_file
			}
		}
		
		
		#This has to be here and will be executed once the generated update script executed
		if(mode == "upgrade")
		{
			readPrefrenceFile()
			restoreUserConfig()
			moveBackUpFiles()
	
			command = "id smxuser"
			if(0 != system(command)){
				commandForSmxuser = "sh " apj_execute_file " apj_note smxuser is already deleted"
				system(commandForSmxuser)
			}else{
				commandForSmxuserDelete = "sh " apj_execute_file " apj_note  Deleting smxuser"
				system(commandForSmxuserDelete)
				#delete_ldap_user()
			}
		
		}
		


	}	
}

########################################

# LDAP configuration changes
function delete_ldap_user()
{
        print "Deleting ldap user"
		ldap_user_delete_script=jbi_cpf_reference_dir"/bin/ldapusr_delete.sh"
		
		commandForlogStart = "sh " apj_execute_file " apj_note " "Execution starts for script : " ldap_user_delete_script " On node " dmgr_hostname
		system(commandForlogStart)
		
		command = "ssh -q "dmgr_hostname" sh " ldap_user_delete_script " smxuser"
		executeSystemCommand(command)
		
		commandForlogForEnd = "sh " apj_execute_file " apj_note " "Execution Ends for script : " ldap_user_delete_script " On node " dmgr_hostname
		system(commandForlogForEnd)
}

function create_ldap_user() {
	#command = "userdel " instance_user
	#system(command)
	 print "Creating ldap user"
	_reference_fileExists = check_fileExists(jbi_swp_reference_dir)
	#reference_path = instance_dir"/smx/mf-conf"
	#_instance_fileExists = check_fileExists(reference_path)
	
	if("EXISTS" == _reference_fileExists)
	{ 
            commandForlogStart = "sh " apj_execute_file " apj_note " "Execution starts for script : /bin/jbi_add_user_sca_repo.sh  On node " dmgr_hostname
			system(commandForlogStart)			
			command = "ssh -q "dmgr_hostname" sh " jbi_cpf_reference_dir "/bin/jbi_add_user_sca_repo.sh " instance_user " " instance_user_id " " home_dir " " login_shell		
					if(0 != system(command)){
									printf "WARN: Failed to add the instance user %s to SCA Repo\n",instance_user
									exit 127
					}
					   printf "INFO: Created jbi user successfully"
					   
			commandForlogStart = "sh " apj_execute_file " apj_note " "Execution Ends for script : /bin/jbi_add_user_sca_repo.sh  On node " dmgr_hostname
			system(commandForlogStart)
    		
			
		
	}	
}
# END: PR-122129ESPE02 MF forks a shell script from the SCA library.

######################################

# read config file for instance
function read_instance_config(_config_file) {

	while (( getline < _config_file ) == 1 )
	{
		#If any comment line found that will be ignored by if check
		if ( $1 !~ /^#/)
		{
			indx =  index($1,":")
			gsub ( "=", " = ")
			_items = split ($0, _line_vector)
			if ( _items == 3 ) 
			{
				# config item
				CONFIG[$1] = $3
			}
			
			if ( _items == 2 ) 
			{
				# component item
				if("JBI_CPF" == substr($1, 1, indx-1) )
				{
					file_name = substr($1, indx+1, length($1))
					reference_path = jbi_cpf_reference_dir "/smx/" file_name
					CONFIG[reference_path] = $2
					
				}else if("MF_SWP" == substr($1, 1, indx-1) )
				{
					file_name = substr($1, indx+1, length($1))
					reference_path = mf_swp_reference_dir "/smx/" file_name  
					CONFIG[reference_path] = $2

				}else if("INST_DIR" == substr($1, 1, indx-1) )
				{	
					folder_create = substr($1, indx+1, length($1))
					FOLDERCREATE[folder_create] = $2
					
				}else if("JBI_SWP" == substr($1, 1, indx-1) )
				{	
					file_name = substr($1, indx+1, length($1))
					reference_path = jbi_swp_reference_dir "/smx/" file_name  
					CONFIG[reference_path] = $2
				}
			
				#CONFIG[installpath] = $2
			}	

		}

		
	}
	
	#instance_user_group = CONFIG["instance_user_group"]
	########################## prepare multicast address,
        if ( length(AS1_IP) ==  0 ) #AS1_IP is empty then multi cast address is 224.0.0.0
        {
             multicast_address = "224.0.0.0"
        }
        else
        {
				   #command  = "grep -iw " AS1_IP " /etc/hosts | awk '{print $1}'"
				   #command  = "getent hosts " AS1_IP " | awk '{print $1}'"
				    command  = "gethostip " AS1_IP " | awk '{print $2}'"
				   command | getline  node_ip
				   
				   command1 = "sh " apj_execute_file " apj_note " node_ip
				   system(command1)
				   
				   if ( null == node_ip )
				   { 
				            commentString = "ERROR: could not get IP address from hosts file, exiting\n" _comment
							commanddebug = "sh " apj_execute_file " apj_note " commentString
							system(commanddebug)
							
							exit 1
				   }
			   dot_position = 0
			   dot_position = index(node_ip,".")
			   last_three_digits_of_ip = substr(node_ip,dot_position+1)
          multicast_address = "224." last_three_digits_of_ip
        }
        if ( null == multicast_address )
        {
          printf "ERROR: failed to generate multicast address, exiting\n"
          #printf "ERROR: failed to generate multicast address, exiting\n" > debug_file
          exit 129
        }
        else
        {
	     #printf "INFO: Successfully generated multicast address to be used in jgroups.xml and replsync.xml \n" > debug_file	
             printf "\n INFO: Successfully generated multicast address to be used in jgroups.xml and replsync.xml\n" multicast_address
             printf "\n"
	}
    #####################end of preparing multicast address

       
}



function file_link(_reference, _attribute) {

	
	_component = substitute_Path(substitute_smx(_reference))
	if( "DIR" == check_isDirectory(getBaseDirectory(_reference)"smx_standby") )
	{
		_currentReference=substitute_smx(_reference)
	}
	else{
		_currentReference=_reference
	}
	_reference_fileExists = check_fileExists(_currentReference)

	
	if("EXISTS" == _reference_fileExists)
	{	
				command1 = "test -h " _component
				if (!system(command1))
				{
					 printf "INFO:Attribute : %s. No link required as file %s exists\n",_attribute,_component > debug_file
					 printf "\necho \"Attribute : %s. No link required as file %s exists\"\n",_attribute,_component > script_file
				}
				else{
				
					printf "\necho \"Attribute: %s - component: %s Soft-link to instance: %s\"\n", _attribute, _reference, service_name > script_file
					printf "INFO: Attribute : %s - component: %s Soft-link to instance: %s\n", _attribute, _reference, service_name > debug_file
					
					# Below command to ensure that if copy of the file is made during install and during upgrade it would have been changed to link.
					# So before create link remove the file by the same name

					printf "apj_execute /bin/rm -rf %s\n", _component > script_file
					printf "apj_execute /bin/ln -s %s %s\n", _reference, _component > script_file	
					printf "apj_execute /bin/chown -h %s:sysop %s\n", instance_user ,_component > script_file	
				}
	}else{
	
			printf "ERROR: The specified component %s not exists at reference side and also not in MF component removed list\n",_reference
			printf "ERROR: The specified component %s not exists at reference side and also not in MF component removed list\n",_reference > debug_file
			exit 130

	}			

	
}




function create_remove_folder(_FOLDERCREATE){
	#Creating parent folder for data folder
	printf "apj_execute /usr/bin/install -d --mode=750 --group=sysop --owner=%s  /var/%s/\n",instance_user,instance_dir > script_file
	
	# Instance specific lib folder is created
	printf "\necho \"Creating directory for instance specific lib\"\n" > script_file
	printf "apj_execute /usr/bin/install -d --mode=750 --group=sysop --owner=%s  %s/smx_standby/%s-lib\n",instance_user,instance_dir,service_name > script_file
	
	printf "apj_execute /bin/ln -f -s -T %s/smx/lib %s/smx_standby/jbi_swp-lib\n",jbi_swp_reference_dir,instance_dir > script_file
	
	printf "apj_execute /bin/chown -h %s:sysop %s\n",instance_user,instance_dir > script_file
	#Relaxing permissions for FileDC
	printf "apj_execute /bin/chmod 770 %s\n",instance_dir > script_file
	printf "apj_execute /bin/chown -h %s:sysop %s/smx_standby/jbi_swp-lib\n",instance_user,instance_dir > script_file
	
	
	#Creating directory for instance-specific log folder (As this has to be created by root)	
	printf "\necho \"Creating directory for instance specific log\"\n" > script_file
	printf "apj_execute /usr/bin/install -d --mode=750 --group=sysop --owner=%s /var/opt/oss/log/%s\n",instance_user,service_name > script_file
		
	#Creating directory for instance-specific NSN-mf_component log folder 	
	printf "\necho \"Creating directory for instance specific NSN-mf_component log\"\n" > script_file
	printf "apj_execute /usr/bin/install -d --mode=750 --group=sysop --owner=%s /var/opt/oss/log/%s/NSN-mf_component\n",instance_user,service_name > script_file
	
	
	for ( i in FOLDERCREATE )
	{
		if(FOLDERCREATE[i] == "folder")
		{
			printf "\necho \"Creating directory for %s\"\n",i > script_file
			printf "apj_execute /usr/bin/install -d --mode=750 --group=sysop --owner=%s  %s/smx_standby/%s\n",instance_user,instance_dir,i > script_file				

		}else if (FOLDERCREATE[i] == "obsolete")
		{
			printf "\necho \"Removing directory for %s\"\n",i > script_file
			printf "apj_execute /bin/rm -rf %s/smx_standby/%s\n",instance_dir,i > script_file		

		}else
		{
			printf "ERROR: Wrong option for folder. Folder can have folder/obsolete option"
			printf "ERROR: Wrong option for folder. Folder can have folder/obsolete option" > debug_file
			exit 130
		}	
	}
	
		
	
}

function copy_file(_reference, _attribute, file_name)
{

	_component = substitute_Path(substitute_smx(_reference))

	if( "DIR" == check_isDirectory(getBaseDirectory(_reference)"smx_standby") )
	{
	_reference=(substitute_smx(_reference))
	}

	_reference_fileExists = check_fileExists(_reference)	
	
	if( (_attribute == COPY_NO_UPDATE) && ("EXISTS" == _reference_fileExists) )
	{
		
		#First command to check component is file or folder exists or not. Second for to check link exists or not
				
		_component_fileExists = check_fileExists(_component)
		command = "test -h " _component

		if ( ("EXISTS" == _component_fileExists) && (0 != system(command)) )
		{
			 printf "INFO: %s exists so no copy required as attribute is %s\n",_component, _attribute > debug_file
		}
		else{
				printf "INFO: Attribute - %s Copying file to %s\n",_attribute,_component > debug_file
				printf "\necho \"Attribute - %s Copying file to %s\"\n",_attribute, _component > script_file
			
				fileModify_commands(_reference, file_name)
			
				# Remove command to remove if soft link is present for the same file. This will case during instance creation file marked as link and during upgrade same file marked as copy
				#In tmp_dir the modified refrence file (along with all sed commands) will exists
				 
				 printf "apj_execute rm -rf %s\n", _component > script_file
				 printf "apj_execute cp --backup=numbered -rf %s %s >> %s 2>&1\n", tmp_dir"/"file_name, _component, debug_file > script_file
				 printf "apj_execute chmod -R 640 %s  >> %s 2>&1\n",_component,debug_file > script_file
				 printf "apj_execute chown %s:sysop -R  %s >> %s 2>&1\n",instance_user,_component,debug_file > script_file
				 printf "REVAL=$?; if [ $REVAL -ne 0 ]; then echo \"ERROR: Copy command failed with return code $REVAL for component %s\"; exit 27; fi \n",_component> script_file	
		}


	}else if( ( (_attribute == COPY_RESTORE_UPDATE) || (_attribute == COPY_UPDATE) ) && ("EXISTS" == _reference_fileExists) )
	{
		#First command to check component is file or folder exists or not. Second for to check link exists or not
		
		_component_fileExists = check_fileExists(_component)	
		command = "test -h " _component
		
		
		if (  ("EXISTS" == _component_fileExists) && (0 != system(command))  )
		{
			
			#Before comparing, all the file modifying commands (sed commands) will be executed in compare_file method
			RETVALUE = compare_file(_reference,_component,file_name)
			

			#command = "diff -iEbwBa " _reference " " _component " > /dev/null 2>&1"
			
			if (RETVALUE == "SAME")
			{
				printf "INFO: Attribute - %s. %s exist and has no update \n",_attribute,_component > debug_file
				printf "\necho \"Attribute - %s. %s exist and has no update\"\n",_attribute,_component > script_file

			}else
			{
				printf "INFO: Attribute - %s. %s exist and has a update. It is copied \n",_attribute,_component > debug_file
				printf "\necho \"Attribute - %s. %s exist and has a update\"\n",_attribute,_component > script_file
				
				#In tmp_dir the modified refrence file (along with all sed commands) will exists
				PATTERN=".~*"
                printf "apj_execute rm -rf %s%s >> %s 2>&1\n", _component, PATTERN, debug_file > script_file
				printf "apj_execute cp  --backup=numbered -rf %s %s >> %s 2>&1\n", tmp_dir"/"file_name, _component, debug_file > script_file
				printf "apj_execute chmod -R 640 %s  >> %s 2>&1\n",_component,debug_file > script_file
			    printf "apj_execute chown %s:sysop -R  %s >> %s 2>&1\n",instance_user,_component,debug_file > script_file
				printf "REVAL=$?; if [ $REVAL -ne 0 ]; then echo \"ERROR: Copy command failed with return code $REVAL for component %s\"; exit 27; fi \n",_component > script_file	
				
				
				#If attribute has copy_restore_updat means restore the user configured value after upgrade
				if( _attribute == COPY_RESTORE_UPDATE)
				{
					RESTORE_FILE_LIST[file_name] = _component
				}
			}

		}else{
			 printf "INFO: Attribute - %s Copying file to %s\n",_attribute,_component > debug_file
			 printf "\necho \"Attribute - %s Copying file to %s\"\n",_attribute, _component > script_file
			
			fileModify_commands(_reference, file_name)
				
			# Remove command to remove if soft link is present for the same file. This will case during instance creation file marked as link and during upgrade same file marked as copy
	  		 printf "rm -rf %s\n", _component > script_file

			 #In tmp_dir the modified refrence file (along with all sed commands) will exists
			 printf "apj_execute cp --backup=numbered -rf %s %s >> %s 2>&1\n", tmp_dir"/"file_name, _component, debug_file > script_file
			 printf "apj_execute chmod -R 640 %s  >> %s 2>&1\n",_component,debug_file > script_file
			 printf "apj_execute chown %s:sysop -R  %s >> %s 2>&1\n",instance_user,_component,debug_file > script_file
			 printf "REVAL=$?; if [ $REVAL -ne 0 ]; then echo \"ERROR: Copy command failed with return code $REVAL for component %s\"; exit 27; fi \n",_component > script_file
			 
		}

	
	}else{
	
		printf "ERROR: The specified component %s not exists at reference side and also not in MF component removed list\n",_reference
		printf "ERROR: The specified component %s not exists at reference side and also not in MF component removed list\n",_reference > debug_file
		exit 130

	}
	
	
}

function compare_file(_reference_path,_component_path,filename)
{
	fileModify_commands(_reference_path,filename)
	
	command = "diff -iEbwBa "  tmp_dir"/"filename " " _component_path " > /dev/null 2>&1"
	if(!system(command))
	{
		return("SAME")
	}else
	{
		return("DIFFERENT")
	}
}


function delete_file(_reference, _attribute) {

    _component = substitute_Path(substitute_smx(_reference))

	
	printf "INFO: Attribute : %s - component: %s in instance: %s is removed\n", _attribute, _component, service_name > debug_file
	printf "\necho \"INFO: Attribute : %s - component: %s in instance: %s is removed\"\n", _attribute, _component, service_name > script_file
	printf "apj_execute rm -rf %s\n", _component > script_file
}		
	
	
function backup_debug(_debug_file)
{
	command = "test -f " _debug_file
	
	if ( !system(command) )
	{
		command = "/bin/mv --backup=numbered " _debug_file " " debug_file_location "/backup/" service_name "_" mode "_" "debug.txt"
		executeSystemCommand(command)
	}

}


function substitute_Path(_refpath)
{ 
	_component_path = _refpath
	
	
	if (jbi_cpf_reference_dir == substr(_component_path, 1, length(jbi_cpf_reference_dir)) ){
		sub (jbi_cpf_reference_dir, instance_dir, _component_path)

	}else if (mf_swp_reference_dir == substr(_component_path, 1, length(mf_swp_reference_dir)) ){
		sub (mf_swp_reference_dir, instance_dir,_component_path) 

	}else if (jbi_swp_reference_dir == substr(_component_path, 1, length(jbi_swp_reference_dir)) ){
			sub (jbi_swp_reference_dir, instance_dir,_component_path)
			sub ("lib", service_name"-lib",_component_path)
			
	}

	return (_component_path)
}

function substitute_smx(_refpath)
{ 
	_reference=_refpath
	
	if (jbi_cpf_reference_dir == substr(_refpath, 1, length(jbi_cpf_reference_dir)) ){
		sub(jbi_cpf_reference_dir"/smx",jbi_cpf_reference_dir"/smx_standby",_reference) 
	}else if (mf_swp_reference_dir == substr(_refpath, 1, length(mf_swp_reference_dir)) ){
		sub(mf_swp_reference_dir"/smx",mf_swp_reference_dir"/smx_standby",_reference)

	}else if (jbi_swp_reference_dir == substr(_refpath, 1, length(jbi_swp_reference_dir)) ){
			sub(jbi_swp_reference_dir"/smx",jbi_swp_reference_dir"/smx_standby",_reference)
			
	}

	return (_reference)
}


#This function checks only for existance of file and folder not for soft link files
function check_fileExists(_file_path)
{
		command1 = "test -f " _file_path
		command2 = "test -d " _file_path
		command3 = "test -h " _file_path
		
		if (  ( !system(command1) || !system(command2) || !system(command3) ) )
		{
			return ("EXISTS")
			
		}else{
			
			return ("NOT_EXISTS")
		}

}

function check_isDirectory(_file_path)
{
		command = "test -d " _file_path
		
		if (!system(command))
		{
			return ("DIR")
			
		}else{
			
			return ("NOT_DIR")
		}

}
#Temporary solution and should be removed after all the mediations have changed the log folder location
function check_isLink(_file_path)
{
	command = "test -h " _file_path
	
	if (!system(command))
	{
		return ("LINK")
	}else{
		return ("NOT_LINK")
	}
}


function fileModify_commands(_reference_path, _filename)
{

	CPF_HOME=instance_dir"/smx_standby"
	CPF_HOME_SMX=instance_dir"/smx"
	command = "hostname"
	command | getline HOST_NAME
			
	i = 0
		
	_COMMAND[i++] = "/bin/mkdir -p " tmp_dir
	_COMMAND[i++] = "/bin/cp -rf " _reference_path " " tmp_dir
	
	#To check the refrence path is folder or not. If folder no need to execute sed commands
	command = "test -d " _reference_path
	
	if (system(command))
	{
		_COMMAND[i++] = "sed -i -e 's:$MF_HOME/mf-smx:'\"" CPF_HOME "\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:$MF_HOME/mf-non_stanbdy:'\"" CPF_HOME_SMX "\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:$MF_HOME/logs-installation:'\"" instance_dir "/logs-installation\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:$MF_HOME:'\"" instance_dir "\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:JBI_USER_NAME:'\"" service_name"_USER_NAME\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:$INSTANCE_USER:'\"" instance_user"\"':ig' " tmp_dir "/" _filename
		_COMMAND[i++] = "sed -i -e 's:NETACT_CLUSTER_ID_PLACEHOLDER:'\"" netact_cluster_id "\"':ig' " tmp_dir "/" _filename
		
		#The below one will be used if jbismxmoniter script ie specified
		_COMMAND[i++] = "sed -i -e 's:$SERVICE_NAME:'\"" service_name "\"':ig' " tmp_dir "/" _filename
		
		#This is used to create DB SCHEMA name for each instance
		_COMMAND[i++] = "sed -i -e 's:$DB_SCHEMA:'\"" substr(toupper(service_name),1,18) "\"':ig' " tmp_dir "/" _filename
		
		#This is used to create update JGroup multicast port
		_COMMAND[i++] = "sed -i -e 's:$JGroup_port:'\"" jgroups_Port "\"':ig' " tmp_dir "/" _filename	

        #This is used to create update  multicast address
       	_COMMAND[i++] = "sed -i -e 's:$mcast_address:'\"" multicast_address "\"':ig' " tmp_dir "/" _filename		
		
		
	}
	
	if("servicemix.conf" == _filename)
	{
		_COMMAND[i++] = "sed -i -e '$a\\load ${servicemix.home}/" service_name"-lib/*.jar' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		_COMMAND[i++] = "sed -i -e '$a\\load ${servicemix.home}/jbi_swp-lib/*.jar' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
	}
	
	if("servicemix.properties" == _filename)
	{
		# updating the rmi port. replacinf rmi.port with rmi.port=value	
		_COMMAND[i++] = "sed -i '/rmi.port[ \t]*=/c\\rmi.port = " rmi_port "' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
		# updating the ActiveMQ port
		_COMMAND[i++] = "sed -i '/activemq.port[ \t]*=/c\\activemq.port = " amq_port "' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
	}
	
	 if("MFC.sh" == _filename)
        {
                printf "INFO: Replacing MF_HOME in MFC.sh with instance directory %s \n", instance_dir > debug_file
                # Replace INST_HOME with the instance directory
		# sed -i -e 's:MF_HOME:'\"/var/opt/oss/log/service_name/\"':ig' 
		_COMMAND[i++]=  "sed -i -e 's:MF_HOME:'\"" instance_dir "/\"':ig' "  tmp_dir "/" _filename " >> " debug_file " 2>&1"
                # Replace RMI_PORT with the port number
                printf "INFO: Replacing RMI_PORT in MFC.sh with port number %s \n", rmi_port > debug_file
                _COMMAND[i++] = "sed -i 's/RMI_PORT/" rmi_port "/g' "  tmp_dir "/" _filename " >> " debug_file " 2>&1"

        }
	
	 
	# updating the ActiveMQ.xml file
	if("activemq.xml" == _filename)
	{	
		
		_COMMAND[i++] = "sed -i '/transportConnector uri/c\\<amq:transportConnector uri=\\\"tcp://0.0.0.0:\\${activemq.port}\\\" />' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		_COMMAND[i++] = "sed -i '/<amq:networkConnector uri=\\\"multicast:/c\\<\\!--<amq:networkConnector uri=\\\"multicast://default\\\"/>-->' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		_COMMAND[i++] = "sed -i -e 's:$BROKER_NAME:'\"" HOST_NAME"_"service_name "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
	
	}	
			
	# updating the Log4j
	if( ("log4j.xml" == _filename))
	{
		_COMMAND[i++] = "sed -i -e 's:data/log/:'\"/var/opt/oss/log/" service_name "/\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	}
	
	# updating the logging properties for change audit
	if( ("logging.properties" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:data/log/oss_change:'\"/var/opt/oss/log/audit/oss_change-" service_name "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	}
	# updating the logging properties for security audit
	if( ("logging.properties" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:data/log/oss_security:'\"/var/opt/oss/log/audit/oss_security-" service_name "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	}
	
	# updating the logging properties for mf component
	if( ("logging.properties" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:data/log/:'\"/var/opt/oss/log/" service_name "/\NSN-mf_component/\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	}
	
	# updating the DefaultLock
	if( ("mf.properties" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:DefaultLockCluster:'\"DefaultLockCluster"service_name HOST_NAME "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	}
	
	# updating the replSync-service.xml
	if( ("replSync-service.xml" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:JBossCache-Cluster:'\"JBossCacheCluster"service_name HOST_NAME "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
	
	}
	
	# updating the infinispanConfig.xml
	if( ("infinispanConfig.xml" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:InfinispanCluster:'\"InfinispanCluster"service_name HOST_NAME "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		
	
	}
	
	if( ("replSync-service.xml_oracleDbSingleNode" == _filename) )
	{
		_COMMAND[i++] = "sed -i -e 's:JBossCache-Cluster:'\"JBossCacheCluster"service_name HOST_NAME "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
	
	}
	if( ("servicemix" == _filename) )
	{	
		if ( null != java_min_heap_memory )
		{
			_COMMAND[i++] = "sed -i -e 's:JAVA_MIN_MEM=256M:'\"JAVA_MIN_MEM="java_min_heap_memory "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"
		}	
		
		if ( null != java_max_heap_memory )
		{		
			_COMMAND[i++] = "sed -i -e 's:JAVA_MAX_MEM=512M:'\"JAVA_MAX_MEM="java_max_heap_memory "\"':ig' " tmp_dir "/" _filename " >> " debug_file " 2>&1"			
		}
	}	
	
	command_length = length(_COMMAND)
	for (i=0; i < command_length; i++ )
	{
		system(_COMMAND[i])
		#printf "Command[%s]: %s\n",i,_COMMAND[i]
	}
	
	#Deleting the array list
	for(i in _COMMAND)
	{
		delete _COMMAND[i]
	}
}
function readBackUpFile(_backUp_file)
{
	while (( getline < _backUp_file ) == 1 )
	{
		if ( $1 !~ /^#/ )
		{
			gsub ( "=", " = ")
			_items = split ($0, _line_vector)
				
			if ( _items == 3 ) 
			{
					# config item
					PROPERTY_KEY_VALUE[$1] = $3
			}		
		}
	}

}

function readPrefrenceFile()
{
		preferneceFile = jbi_cpf_reference_dir "/conf/copy_restore_preference.properties"
		count = 1
        while (( getline < preferneceFile ) == 1 )
        {
                if ( $1 !~ /^#/ )
                {
                        PREFERENCE_KEY_VALUE[count++] = $1
                }
        }
}

function checkKeyInPreferenceFile(_key){
        for ( _x in PREFERENCE_KEY_VALUE ) {
                        if ( PREFERENCE_KEY_VALUE[_x] == _key ) {
								command = "sh " apj_execute_file " apj_note " "Match found in copy_restore_preference.properties for " PREFERENCE_KEY_VALUE[_x]
								system(command)
                                IS_PREFERENCE="yes"
                                break
                        }
                        else{
                                IS_PREFERENCE="no"
                        }
                }
}

function restoreValue(_file_to_restore)
{
	#Write the command directly to script instead executing from here
	
	for ( _KEY in PROPERTY_KEY_VALUE )
	{
		checkKeyInPreferenceFile(_KEY)
		if ( IS_PREFERENCE == "yes" )
			{
				command = "sh " apj_execute_file " apj_note " "Updating New value of " _KEY
				system(command)
			}
		else
			{
				command = "sh " apj_execute_file " apj_note " "Restoring old value of " _KEY
                system(command)
				command = "sed -i '/" _KEY "[ \t]*=/c\\" _KEY "=" PROPERTY_KEY_VALUE[_KEY] "' " _file_to_restore
				system(command)
		}
		
	}
}

function restoreUserConfig()
{
	#listOfFileToRestore(restoreFileListPath)
	for (filename in RESTORE_FILE_LIST)
	{
		#The backup file will be in the form of filename.~1~
		
		#file_to_restore = instance_dir "/smx/" RESTORE_FILE_LIST[i]
		file_to_restore = RESTORE_FILE_LIST[filename]
		backUp_file = file_to_restore".~1~"
				
		if("EXISTS" == check_fileExists(backUp_file) )
		{
			printf "%s file exists",file_to_restore > debug_file
			readBackUpFile(backUp_file)
			restoreValue(file_to_restore)
			
		}else{
		
			printf "%s file not exists/No updates. No need to restore values",file_to_restore > debug_file
		}
	}
}


function moveBackUpFiles()
{
		#Moving all the backed up file to /var/opt/oss/log/NSN-jbi_cpf/back_up/<service_name_folder>
		command = "/bin/mkdir -p /var/opt/oss/log/NSN-jbi_cpf/back_up/" service_name
		executeSystemCommand(command)
			
		command = "find " instance_dir"/smx -name \\*.~1~"
		while ( command | getline backup_file_path > 0)
		{
			if (null != backup_file_path)
			{
				command1 = "/bin/mv --backup=numbered " backup_file_path " /var/opt/oss/log/NSN-jbi_cpf/back_up/" service_name
				executeSystemCommand(command1)
			}
			else
			{
				 printf "ERROR: specified %s does not exist at the refrence location\n",_path_ > debug_file
			}
		}
}

function deleteFolder(_folder_to_remove)
{
	command = "/bin/rm -rf " _folder_to_remove
	executeSystemCommand(command)
}


function create_service_link()
{
	#Empty files are created at /etc/init.d/ as it is required by smanager.pl (used to stop/start services in RHCS) script
	command = "hostname -s"
	command | getline HOST_NAME

	printf "\nHOSTLIST=\"\"\n" > script_file
	printf "\nHOSTLIST=`grep NODES_HOSTNAME_IN_ROLE /opt/oss/NSN-jbi_cpf/conf/DCA_Variables.txt`\n"	> script_file
	printf "\nHOSTLIST=${HOSTLIST:23}\n" > script_file
	printf "\nHOSTLIST=(${HOSTLIST})\n" > script_file

	printf "\nif [ \"$HOSTLIST\" = \"\" ]\
	\nthen\
		\necho \" ======Empty HOSTLIST. Not creating soft links===========\"\
		\necho \" ======Empty HOSTLIST. Not creating soft links===========\" >> %s 2>&1\
	\nfi\n",debug_file > script_file	
	
	printf "\nif [ `grep %s-%s /etc/cluster/cluster.conf | wc -l` -gt 0 ]\
	\nthen\
		\nfor HOST in ${HOSTLIST[*]};\
		\ndo\
			\ntouch /etc/init.d/%s-$HOST\
			\ntest -h /etc/init.d/%s-$HOST\
			\nRET_VAL=$?\
			\nif [ $RET_VAL -ne 0 ]\
				\nthen\
				\n/bin/chown -h %s:sysop /etc/init.d/%s-$HOST\
				\n/bin/chmod 750 /etc/init.d/%s-$HOST\
			\nfi\
		\ndone\
	\nelse\
		\necho \" ======Grep command did not find any matching pattern. Not creating soft links===========\"\
		\necho \" ======Grep command did not find any matching pattern. Not creating soft links===========\" >> %s 2>&1\
	\nfi\n",service_name,HOST_NAME,service_name,service_name,instance_user,service_name,service_name,debug_file > script_file	
	
}

function validate()
{
	instance_dir = CONFIG["instance_dir"]
	service_name = CONFIG["service_name"]
	amq_port = CONFIG["amq_port"]
	rmi_port = CONFIG["rmi_port"]
	jgroups_Port = CONFIG["jgroups_Port"]
	instance_user = CONFIG["instance_user"]
	instance_user_id = CONFIG["instance_ldapid"]
	home_dir = CONFIG["home_dir"]
	login_shell = CONFIG["login_shell"]
	netact_cluster_id = CONFIG["NETACT.TARGET.ID"]
	dmgr_hostname=CONFIG["WAS.DMGR_HOSTNAME"]
	
	# Added for asigning JAVA HEAP Memory
	java_min_heap_memory = CONFIG["java_min_heap_memory"]
	java_max_heap_memory = CONFIG["java_max_heap_memory"]
	
	 debug_file = debug_file_location "/" service_name "_" mode "_" "debug.txt"
		backup_debug(debug_file)

	if(null == instance_dir || null == service_name || null == amq_port || null == rmi_port || null ==instance_user)
	{
		printf "ERROR: One of the parameters has a null value (instance_dir,rmi_port,amq_port,service_name,instance_user) in config file\n"
		printf "ERROR: One of the parameters has a null value (instance_dir,rmi_port,amq_port,service_name,instance_user) in config file\n" > debug_file
		exit 129
	}
	
	if(null == jgroups_Port)
	{
		printf "WARNING: JGroup port parameter has a null value in config file and port is set to default value\n"
		printf "WARNING: JGroup port parameter has a null value in config file and port is set to default value\n" > debug_file
		jgroups_Port = "45588"
	}
	
	if(null == instance_user_id)
	{
		printf "INFO: instance_ldapid parameter is not specified in the config file\n"
		instance_user_id = 0;
	}
	
	if (null == home_dir)
	{
		printf "INFO: home_dir parameter is not specified in the config file\n"
		home_dir = "/home/"instance_user;
	}
	
	if (null == login_shell)
	{
		printf "INFO: login_shell parameter is not specified in the config file\n"
		login_shell = 0;
	}
	
	
	if(null == netact_cluster_id)
	{
		printf "WARNING: NETACT_CLUSTER_ID has a null value in DCA Variable list file and is set to default value\n"
		printf "WARNING: NETACT_CLUSTER_ID has a null value in DCA Variable list file and is set to default value\n" > debug_file
		netact_cluster_id = "1"
	}
	printf "============================= Script Generation for %s Started at %s==================================\n",mode,strftime() > debug_file
	printf "INFO: Instance Directory : %s\n Service Name : %s\n ActiveMQ Port : %s\n RMI Port : %s\n Instance User : %s\n",instance_dir,service_name,amq_port,rmi_port,instance_user  > debug_file
	
	if ( DEBUG ) {
		printf "------------------\n%s --> CONFIG\n", _config_file > debug_file
		for ( _i in CONFIG ) { printf "%s -- %s\n", _i, CONFIG[_i] > debug_file }
	}
}

function updateSystemENV()
{
		#Creating instance home directory variable to /etc/profile.d/NSN-jbi_cpf.sh

		printf "\necho \"Creating INSTANCE HOME directory variables \"\n" > script_file
		printf "env_variable_file=/etc/profile.d/NSN-jbi_cpf.sh\n" > script_file
		printf "apj_execute /bin/touch $env_variable_file\n" > script_file
		printf "\nsed -i '/%s_HOME/d' $env_variable_file\
		\nif [[ $(grep %s_HOME= $env_variable_file | wc -l) -lt 1 ]]; then\
		\necho \"installation_home set to %s\"\
		\necho \"%s_HOME=%s\" >> $env_variable_file\
		\necho \"export %s_HOME\" >> $env_variable_file\
		\nsource $env_variable_file\
		\nfi\n", toupper(service_name),toupper(service_name),instance_dir,toupper(service_name),instance_dir,toupper(service_name)  > script_file
		
		# Updating profiles for instance user to /etc/profile.d/NSN-jbi_cpf.sh

		printf "\necho \"Creating INSTANCE USER variables \"\n" > script_file
		printf "\nsed -i '/%s_USER_NAME/d' $env_variable_file\
		\nif [[ $(grep %s_USER_NAME= $env_variable_file | wc -l) -lt 1 ]]; then\
		\necho \"%s_USER_NAME set to %s\"\
		\necho \"%s_USER_NAME=%s\" >> $env_variable_file\
		\necho \"export %s_USER_NAME\" >> $env_variable_file\
		\nsource $env_variable_file\
		\nfi\n", toupper(service_name),toupper(service_name),toupper(service_name),instance_user,toupper(service_name),instance_user,toupper(service_name)  > script_file
		
		printf "\nsed -i '/%s_HOME/d' ~/.bash_profile\
		\nif [[ $(grep %s_HOME= ~/.bash_profile | wc -l) -lt 1 ]]; then\
		\necho \"installation_home set to %s\"\
		\necho \"%s_HOME=%s\" >> ~/.bash_profile\
		\necho \"export %s_HOME\" >> ~/.bash_profile\
		\nsource ~/.bash_profile\
		\nfi\n", toupper(service_name),toupper(service_name),instance_dir,toupper(service_name),instance_dir,toupper(service_name)  > script_file

		printf "\nsed -i '/%s_HOME/d' /etc/profile\
		\nif [[ $(grep %s_HOME= /etc/profile | wc -l) -lt 1 ]]; then\
		\necho \"installation_home set to %s\"\
		\necho \"%s_HOME=%s\" >> /etc/profile\
		\necho \"export %s_HOME\" >> /etc/profile\
		\nsource /etc/profile\
		\nfi\n", toupper(service_name),toupper(service_name),instance_dir,toupper(service_name),instance_dir,toupper(service_name)  > script_file

		printf "\nsed -i '/%s_HOME/d' ~/.bashrc\
		\nif [[ $(grep %s_HOME= ~/.bashrc | wc -l) -lt 1 ]]; then\
		\necho \"installation_home set to %s\"\
		\necho \"%s_HOME=%s\" >> ~/.bashrc\
		\necho \"export %s_HOME\" >> ~/.bashrc\
		\nsource ~/.bashrc\
		\nfi\n", toupper(service_name),toupper(service_name),instance_dir,toupper(service_name),instance_dir,toupper(service_name)  > script_file

		# Updating profiles for instance user

		printf "\nsed -i '/%s_USER_NAME/d' ~/.bash_profile\
		\nif [[ $(grep %s_USER_NAME= ~/.bash_profile | wc -l) -lt 1 ]]; then\
		\necho \"%s_USER_NAME set to %s\"\
		\necho \"%s_USER_NAME=%s\" >> ~/.bash_profile\
		\necho \"export %s_USER_NAME\" >> ~/.bash_profile\
		\nsource ~/.bash_profile\
		\nfi\n", toupper(service_name),toupper(service_name),toupper(service_name),instance_user,toupper(service_name),instance_user,toupper(service_name)  > script_file

		printf "\nsed -i '/%s_USER_NAME/d' /etc/profile\
		\nif [[ $(grep %s_USER_NAME= /etc/profile | wc -l) -lt 1 ]]; then\
		\necho \"%s_USER_NAME set to %s\"\
		\necho \"%s_USER_NAME=%s\" >> /etc/profile\
		\necho \"export %s_USER_NAME\" >> /etc/profile\
		\nsource /etc/profile\
		\nfi\n", toupper(service_name),toupper(service_name),toupper(service_name),instance_user,toupper(service_name),instance_user,toupper(service_name)  > script_file
}

function printStart(_comment)
{
	commentString1 = "Executing:::: " _comment
	command1 = "sh " apj_execute_file " apj_note " commentString1
	system(command1)
}

function printEnd(_comment)
{
	commentString2 = "Finished::::: " _comment
	command2 = "sh " apj_execute_file " apj_note " commentString2
	system(command2)
}

function executeSystemCommand(_command)
{
	sh_command1 = "sh " apj_execute_file " " _command
	status = system(sh_command1)
	if (status !=0 )
	{
	print "executeSystemCommand failed for " _command ". Exiting with code " status
	exit status
	}

}

function executeSystemScript(_command)
{
	sh_command2 = "sh " apj_execute_file " script " _command
	status = system(sh_command2)
	if (status !=0 )
	{
	print "executeSystemScript failed for " _command ". Exiting with code " status
	exit status
	}
}

function getBaseDirectory(_refpath)
{ 
	_reference=_refpath
	_length=index(_reference, "smx")
	
	_basePathDirectory=substr(_reference, 1, _length-1)
	
	return (_basePathDirectory)
}