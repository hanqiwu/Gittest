
import re
import logging



print_status=0
quot_status =0
quot_location=0

with open(tempfile, 'r') as openfile:
    for num, line in enumerate(openfile):

        if quot_status == 1:
            if re.search(r'\"', line) and not re.search(r'\\\"',
                                                        line):  # If find right quote, reset quot_staus and print_status.
                print_status = 0
                for i, c in enumerate(line):
                    if "\"" == c:
                        quot_location = i  # record the location of right quote. e.g.: printf "ab
                        #                                                 c:cde",abc:def

        if (re.search(r'\s*echo.*', line) or re.search(r'\s*print.*', line)) and print_status != 1:  # Checking whether it's print information.
            print_status = 1

        if print_status == 1:
            if re.search(r'\"', line) and quot_status != 1:  # If find quto, set the status to 1.
                quot_status = 1
                if re.search(r'\".*\"',
                             line):  # If we find right quto in the same line reset the status, and continue to check next line. e.g.: printf "abc"
                    print_status = 0
                    quot_status = 0
                    rule = "\".*\""
                    rule = re.compile(rule)
                    temp = rule.findall(line)
                    templine = line.replace(temp[0], '',
                                            1)  # replace the pirnt information with null. e.g. printf "abc:abc", abc:abc -> printf , abc:abc
                    for i, c in enumerate(templine):  # check special characters in left part.
                        if c in METACHARS:
                            tempchars = re.escape(c)
                            tempchars4 = "\".*" + tempchars + ".*\""
                            tempchars4 = re.compile(tempchars4)
                            if not tempchars4.findall(templine):
                                # striped_line = line.strip("\n")
                                logging.error(
                                    "SE0005: in script: " + tempfile + " special character: \"" + c + "\" line %d: %r should be quoted in \"\"." % (
                                    num, line))
                    continue
        if print_status == 0:  # Only check the special character in non print information.
            for i, c in enumerate(line):
                if i > quot_location:  # Start to search special character after right quote.
                    if c in METACHARS:
                        tempchars = re.escape(c)
                        tempchars1 = "#.*" + tempchars + ".*"
                        tempchars1 = re.compile(
                            tempchars1)  # pattern for commented part contain special character e.g.: #abc:abc

                        tempchars2 = ".*" + tempchars + ".*#"
                        tempchars2 = re.compile(
                            tempchars2)  # pattern for uncommented part contain special character e.g.: abc:abc#cde:cde

                        tempchars3 = "\".*" + tempchars + ".*\""
                        tempchars3 = re.compile(tempchars3)  # pattern for special character in quoted.

                        if tempchars1.findall(line):  # check whether this line has commented content
                            if tempchars2.findall(
                                    line):  # check whether the uncommented part of this line has the special character
                                if not tempchars3.findall(line):
                                    logging.error(
                                        "SE0005: in script: " + tempfile + " special character: \"" + c + "\" line %d: %r should be quoted in \"\"." % (
                                        num, line))
                        else:
                            if not tempchars3.findall(line):
                                # striped_line = line.strip("\n")
                                logging.error(
                                    "SE0005 in script: " + tempfile + " special character: \"" + c + "\" line %d: %r should be quoted in \"\"." % (
                                    num, line))
            quot_location = 0