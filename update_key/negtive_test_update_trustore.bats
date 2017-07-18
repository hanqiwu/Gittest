#!/usr/bin/env bats

setup() {
 mock_helper=0
 mock_cert=0
 mock_root=0
 mock_user=0
 if [ ! -f "/opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh" ]
 then
 	sudo cp -p apj_logging_helper.sh /opt/oss/NSN-jbi_cpf/jbi_logger/
	mock_helper=1
 fi
 if [ ! -f "/var/opt/oss/certificates/adm/ca-cert/" ]
 then
 	sudo mkdir -p /var/opt/oss/certificates/adm/ca-cert/
	mock_cert=1
 fi
}



@test "No parameter" {
        run ./update_trustore.sh
        [ $status = 1 ]
	[[ ${lines[-1]} =~ "Parameter -servicename is mandatory" ]]
}

@test "Wrong parameter" {
        run ./update_trustore.sh -wrongpar
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "Parameter -wrongpar is not needed" ]]
}


@test "No root ca" {
	run ./update_trustore.sh -servicename abc
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "/var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem does not exists, please check root CA generated correctly" ]]
}

@test "No user ca" {
	if [ ! -f "/var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem" ]
	then
		sudo cp -p ./netact.root.ca.pem /var/opt/oss/certificates/adm/ca-cert/
		mock_root=1
	fi
        run ./update_trustore.sh -servicename abc
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "/var/opt/oss/certificates/adm/ca-cert/netact.user.ca.pem does not exists, please check user CA generated correctly" ]]
}

@test "Wrong service name" {	
	if [ ! -f "/var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem" ]
	then
                sudo cp -p ./netact.root.ca.pem /var/opt/oss/certificates/adm/ca-cert/
		mock_root=1
        fi
	if [ ! -f "/var/opt/oss/certificates/adm/ca-cert/netact.user.ca.pem" ]
	then
		sudo cp -p ./netact.user.ca.pem /var/opt/oss/certificates/adm/ca-cert/
		mock_user=1
	fi
        run ./update_trustore.sh -servicename abc
        [ $status = 1 ]
        [[ ${lines[-1]} =~ "Parameter -servicename is not correct" ]]
}




teardown() {

if [ ${mock_user} -eq 1 ]
then
	sudo rm -rf /var/opt/oss/certificates/adm/ca-cert/netact.user.ca.pem
fi

if [ ${mock_root} -eq 1 ] 
then
	sudo rm -rf /var/opt/oss/certificates/adm/ca-cert/netact.root.ca.pem
fi

if [ ${mock_cert} -eq 1 ]
then	
	sudo rm -rf /var/opt/oss/
fi

if [ ${mock_helper} -eq 1 ]
then
	sudo rm -rf /opt/oss/NSN-jbi_cpf/
fi

}
