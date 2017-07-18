. /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh
apj_note "Executing $0..."
date=$(date)
apj_note "Start time is $date"

activateInstallFolder()
{
    if [ -d "/opt/oss/NSN-mf_swp/install_standby" ]; then
        if [ -d "/opt/oss/NSN-mf_swp/install_backup/" ]; then
            apj_execute rm -rf /opt/oss/NSN-mf_swp/install_backup/
        fi
        if [ -d "/opt/oss/NSN-mf_swp/install" ]; then
            apj_note "Taking backup of old install folder for: /opt/oss/NSN-mf_swp/install..."
            apj_execute mv /opt/oss/NSN-mf_swp/install /opt/oss/NSN-mf_swp/install_backup
        fi
        apj_execute mv /opt/oss/NSN-mf_swp/install_standby /opt/oss/NSN-mf_swp/install
    else
        apj_note "/opt/oss/NSN-mf_swp/install_standby doesn't exists"
    fi
}
activateConfFolder()
{
    if [ -d "/opt/oss/NSN-mf_swp/conf_standby" ]; then
        if [ -d "/opt/oss/NSN-mf_swp/conf_backup/" ]; then
            apj_execute rm -rf /opt/oss/NSN-mf_swp/conf_backup/
        fi
        if [ -d "/opt/oss/NSN-mf_swp/conf" ]; then
            apj_note "Taking backup of old conf folder for: /opt/oss/NSN-mf_swp/conf..."
            apj_execute mv /opt/oss/NSN-mf_swp/conf /opt/oss/NSN-mf_swp/conf_backup
        fi
        apj_execute mv /opt/oss/NSN-mf_swp/conf_standby /opt/oss/NSN-mf_swp/conf
    else
        apj_note "/opt/oss/NSN-mf_swp/conf_standby doesn't exists"
    fi
}
activateBinFolder()
{
    if [ -d "/opt/oss/NSN-mf_swp/bin_standby" ]; then
        if [ -d "/opt/oss/NSN-mf_swp/bin_backup/" ]; then
            apj_execute rm -rf /opt/oss/NSN-mf_swp/bin_backup/
        fi
        if [ -d "/opt/oss/NSN-mf_swp/bin" ]; then
            apj_note "Taking backup of old bin folder: /opt/oss/NSN-mf_swp/bin..."
            apj_execute mv /opt/oss/NSN-mf_swp/bin /opt/oss/NSN-mf_swp/bin_backup
        fi
        apj_execute mv /opt/oss/NSN-mf_swp/bin_standby /opt/oss/NSN-mf_swp/bin
    else
        apj_note "/opt/oss/NSN-mf_swp/bin_standby doesn't exists"
    fi
}

prepareUpgradeForInstall()
{
    if [ -d "/opt/oss/NSN-mf_swp/install/" ]; then
        apj_note "Cloning install folder to prepare for upgrade..."
        if [ -d "/opt/oss/NSN-mf_swp/install_standby/" ]; then
            rm -rf /opt/oss/NSN-mf_swp/install_standby/
        fi
        apj_execute cp -RPp /opt/oss/NSN-mf_swp/install /opt/oss/NSN-mf_swp/install_standby
    else
        apj_note "/opt/oss/NSN-mf_swp/install/ folder does not exists,seems to be at the beginning of installation..."
    fi
}
prepareUpgradeForBin()
{
    if [ -d "/opt/oss/NSN-mf_swp/bin/" ]; then
        apj_note "Cloning bin folder to prepare for upgrade..."
        if [ -d "/opt/oss/NSN-mf_swp/bin_standby/" ]; then
            rm -rf /opt/oss/NSN-mf_swp/bin_standby/
        fi
        apj_execute cp -RPp /opt/oss/NSN-mf_swp/bin /opt/oss/NSN-mf_swp/bin_standby
    else
        apj_note "/opt/oss/NSN-mf_swp/bin/ folder does not exists,seems to be at the beginning of installation..."
    fi
}
prepareUpgradeForConf()
{
    if [ -d "/opt/oss/NSN-mf_swp/conf/" ]; then
        apj_note "Cloning conf folder to prepare for upgrade..."
        if [ -d "/opt/oss/NSN-mf_swp/conf_standby/" ]; then
            rm -rf /opt/oss/NSN-mf_swp/conf_standby/
        fi
        apj_execute cp -RPp /opt/oss/NSN-mf_swp/conf /opt/oss/NSN-mf_swp/conf_standby
    else
        apj_note "/opt/oss/NSN-mf_swp/conf/ folder does not exists,seems to be at the beginning of installation..."
    fi
}

count=$#

if [ $count -lt 1 ] || [ $count -gt 1 ]; then
        echo "Invalid arguments";
        usage
fi

if [ "$1" == "standby" ]; then
    if [ -d "/opt/oss/NSN-mf_swp/smx/" ]; then
        apj_note "Cloning existing system to prepare for upgrade..."
        if [ -d "/opt/oss/NSN-mf_swp/smx_standby/" ]; then
            apj_execute rm -rf /opt/oss/NSN-mf_swp/smx_standby/
        fi
        apj_execute cp -RPp /opt/oss/NSN-mf_swp/smx /opt/oss/NSN-mf_swp/smx_standby
        prepareUpgradeForInstall
        prepareUpgradeForConf
        prepareUpgradeForBin
        apj_note "Prepare for upgrade completed."
    else
        apj_note "/opt/oss/NSN-mf_swp/smx/ folder does not exists,seems to be at the beginning of installation..."
    fi

fi

if [ "$1" == "activate" ]; then
    if [ -d "/opt/oss/NSN-mf_swp/smx_standby" ]; then
        apj_note "Taking backup of old MF/mediation folders..."
        if [ -d "/opt/oss/NSN-mf_swp/smx_backup/" ]; then
            rm -rf /opt/oss/NSN-mf_swp/smx_backup/
        fi
        if [ -d "/opt/oss/NSN-mf_swp/smx" ]; then
            apj_execute mv /opt/oss/NSN-mf_swp/smx /opt/oss/NSN-mf_swp/smx_backup
        else
            apj_note "WARNING: /opt/oss/NSN-mf_swp/smx does not exist to take backup!"
        fi
        apj_note "Activating upgrade of MF/mediation..."
        apj_execute mv /opt/oss/NSN-mf_swp/smx_standby /opt/oss/NSN-mf_swp/smx
        activateInstallFolder
        activateConfFolder
        activateBinFolder
        apj_note "Activate upgrade completed."
        apj_note "To see folder permission of /opt/oss/NSN-mf_swp/smx/ after activate check :/var/opt/oss/log/install/NSN-jbi_cpf/folder_permission.txt"
        apj_execute ls -lrt /opt/oss/NSN-mf_swp/smx/ >> /var/opt/oss/log/install/NSN-jbi_cpf/folder_permission.txt
        apj_note "Clean Up started..."
        path=( /opt/oss/NSN-mf_swp/smx/hotdeploy/
            /opt/oss/NSN-mf_swp/smx/Heartbeat/
            /opt/oss/NSN-mf_swp/smx/swp-lib/
            /opt/oss/NSN-mf_swp/smx/passwordchange/lib/)
            # /opt/oss/NSN-mf_swp/smx/pingServer/lib/ )

        for i in "${path[@]}"
        do
            apj_debug "Folder cleanup started for folder ::$i"
            apj_execute_script /opt/oss/NSN-jbi_cpf/install/bin/folder_cleanup.sh $i
        done

        # for upgrade from 15.5 to 16.5 to solve below exception:
        # CWSJE0001E: An inconsistency in the build levels of installed application server client components was detected. The installed build level of client component jar:file:/opt/oss/NSN-mf_swp/smx/passwordchange/lib/orb-8.5.5.7.jar!/com/ibm/ejs/ras/lite/build.properties which is {CMVC_RELEASE=WAS855.SERV1, CMVC_LEVEL=cf071533.01} is different to the build level of client component jar:file:/opt/oss/NSN-mf_swp/smx/passwordchange/lib/client-8.0.0.jar!/com/ibm/ejs/ras/lite/build.properties which is {CMVC_RELEASE=WAS80.SERV1, CMVC_LEVEL=cf021148.03}.
        # Exception in thread "main" java.lang.ExceptionInInitializerError
        if [ -f "/opt/oss/NSN-mf_swp/smx/passwordchange/lib/client-8.0.0.jar" ]; then
            apj_execute rm /opt/oss/NSN-mf_swp/smx/passwordchange/lib/client-8.0.0.jar
        fi

        if [ -f "/opt/oss/NSN-mf_swp/smx/passwordchange/lib/bootstrap-8.0.0.jar" ]; then
            apj_execute rm /opt/oss/NSN-mf_swp/smx/passwordchange/lib/bootstrap-8.0.0.jar
        fi

        apj_note "Clean Up Finished..."

        # Added If check to avoid ping server and tnameserver restart on WAS node..
        # if [ -f "/opt/oss/NSN-jbi_cpf/bin/jbi_instance_stop_start.sh" ]; then
            # apj_execute_script /opt/oss/NSN-jbi_cpf/bin/jbi_instance_stop_start.sh -service pingServer -action restart
            # apj_execute_script /opt/oss/NSN-jbi_cpf/bin/jbi_instance_stop_start.sh -service tnameserver -action restart -haservice tnameserver
        # fi

    else
        apj_note "/opt/oss/NSN-mf_swp/smx_standby doesn't exists"
    fi

fi

date=$(date)
apj_note "End time is $date"
apj_note "Exiting $0"

