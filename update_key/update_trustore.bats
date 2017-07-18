#!/usr/bin/env bats


@test "Simple testing" {
	run ./update_trustore.sh -ssname testss -certname testcert -servicename testservice
	[ $status = 1 ]
	[[ ${lines[0]} =~ "./update_trustore.sh: line 2: /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh: No such file or directory" ]]
	[[ ${lines[-1]} =~ "Parameter -ssname is not needed" ]]
}

@test "Simple testing2" {
        
        run ./update_trustore.sh  -servicename testservice
	[ $status = 1 ]
        [[ ${lines[0]} =~ "./update_trustore.sh: line 2: /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh: No such file or directory" ]]
        [[ ${lines[-1]} =~ "Parameter -ssname is not needed" ]]
}
