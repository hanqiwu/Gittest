#!/usr/bin/env bats
source update_trustore_test.sh


@test "Simple testing" {
        run exitWithErrorCode() test12
        [ $status = 1 ]
        [[ ${lines[0]} =~ "./update_trustore.sh: line 2: /opt/oss/NSN-jbi_cpf/jbi_logger/apj_logging_helper.sh: No such file or directory" ]]
        [[ ${lines[-1]} =~ "Parameter -ssname is not needed" ]]
}
