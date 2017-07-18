#!/usr/bin/env bats

setup() {
 mock_helper=0
 mock_adm=0
 mock_keystore=0

 if [ ! -f "/opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh" ]
 then
 	sudo cp -p apj_logging_helper.sh /opt/oss/NSN-jbi_cpf/jbi_logger/
	mock_helper=1
 fi
 if [ ! -f "/var/opt/oss/certificates/adm/" ]
 then
 	sudo mkdir -p /var/opt/oss/certificates/adm/
	mock_cert=1
 fi
}



@test "No parameter" {
        run ./update_keystore.sh
        [ $status = 1 ]
	[[ ${lines[-1]} =~ "Parameter -ssname is mandatory" ]]
}

@test "Wrong parameter" {
        run ./update_keystore.sh -wrongpar
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "Parameter -wrongpar is not needed" ]]
}


@test "No keystore" {
	run ./update_keystore.sh -ssname abc -certname abc -servicename abc
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "/var/opt/oss/certificates/adm/abc/abc.jks does not exists, please check if Parameter -ssname abc and -certname are correct" ]]
}

@test "Wrong service name" {
	if [ ! -f "/var/opt/oss/certificates/adm/abc/abc.jks" ]
	then
		sudo mkdir -p /var/opt/oss/certificates/adm/abc/
		sudo touch /var/opt/oss/certificates/adm/abc/abc.jks
		mock_keystore=1
	fi
        run ./update_trustore.sh -servicename abc
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "Parameter -servicename is not correct" ]]
}



teardown() {

if [ ${mock_keystore} -eq 1 ]
then
	sudo rm -rf /var/opt/oss/certificates/adm/abc/
fi

if [ ${mock_adm} -eq 1 ]
then	
	sudo rm -rf /var/opt/oss/certificates/adm/
fi

if [ ${mock_helper} -eq 1 ]
then
	sudo rm -rf /opt/oss/NSN-jbi_cpf/
fi

}
