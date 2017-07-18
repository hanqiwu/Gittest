# -*- coding: utf-8 -*
# SE0001 : cp command should be followed with arguments
# SE0002 : should use '${}' when using a variable.
# SE0003 : function should NOT contain exit
# SE0004 : function should contain return
# SE0005 : special character should be quoted in "" .
# SE0006 :
#
#

import sys,getopt
import re
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)






def usage():
    print ("Usage:Doing static check for shell script\n")
    print ("shell_static_check_tool.py [OPTIONS...] FILES...")
def version():
    print "1.01"


def check_cp (tempfile) : #'cp' command should be followed with arguments.

    with open(tempfile,'r') as openfile:
        for num,line in enumerate(openfile):

           if "cp " in line and not re.search(r'^\s*#.*', line):  #contain cp command and the line is not commented.
               check_result=re.search(r'cp\s+\-\S',line)    #check whether the cp command is followed with arguments.
               if check_result:
                    pass
               else:
                   #striped_line=line.strip("\n")
                   logger.error ("SE0001: in script: "+tempfile+" line %d: %r :cp command should be followed with arguments." %(num,line))


def pre_check_file(openfile): #check whether the file is existed before access it.
    pass


def check_return_code(openfile): #Check command execute return code, if next operation depend on last command execution result.
    pass


def check_exit_code(openfile): #check last command result before doing next step if they have dependency.
    pass


def check_variable_brace(tempfile):#use ‘${}’ when using a variable

    with open(tempfile, 'r') as openfile:
        for num,line in enumerate(openfile):
           if "$" in line and not re.search(r'^\s*#.*', line):  #contain $ and the line is not commented.

              check_result=re.search(r'\$\{\S*\}',line)     #check whether use '${}' when using a variable
              if check_result:
                  pass
              else:
                  #striped_line = line.strip("\n")
                  logger.error ("SE0002: in script: "+tempfile+" line %d: %r :should use '${}' when using a variable." %(num,line))


def check_exit_return(tempfile): #No 'exit' is allowed in any function. and return is mandatory in every function.
    func_name = []      #The function found in script
    func_mark = 0       #Record the status for finding structure "xxxx()".

    with open(tempfile, 'r') as openfile:
        for num,line in enumerate(openfile):
       #logger.debug ("Current line is :" + line)

           if func_mark == 1:
              if not re.search(r'^\s*#.*', line): # Not commented line or blank line.
                if re.search(r'^\s*\{', line):
                    func_mark = 0   #If find "{ " in next valid line after "xxxx()", we can make sure that's definition for fuction.
                else:
                    func_mark=0
                    func_name.pop() # if we can't find "{" after in next valid line after "xxxx()", it should not be definition for fuction. we should remove it from func_name

           if (re.search(r'\s*\w*.*\(.*\)\s*', line) or re.search(r'\s*function\s+\w+')) and not re.search(r'^\s*#.*', line) and not re.search(r'\s*if.*', line) and not re.search(r'\s*for.*', line) and not re.search(r'\s*while.*', line) and func_mark == 0:  #Find definition of function and the line is not commented.

              func_mark = 1
              if re.search(r'\s*function\s+\w+\s+'):
                  func_name = func_name + re.findall(r'\s*function\s+\w+\s+', line)
              else:
                  func_name = func_name + re.findall(r'^\w*.*\(.*\)', line)     #If find "xxxx()" structure, store it in func_name
              if re.search(r'\{\s*$', line):    #if we find "{" in the same line with structure "xxxx()" , we can make sure it's definition for fuction.Reset func_mark.
                 func_mark = 0

    logger.debug("The function we find: ")
    logger.debug (func_name)
    for i in func_name:
        check_func_not_contain (tempfile, i, "exit")
    for i in func_name:
        check_func_contain(tempfile, i, "return")


def check_func_not_contain (file_name, function_name, not_contain):

    function_end = 0
    function_content = []
    count_left_bracket = 0
    count_right_bracket = 0
    find_status = 0

    es_function_name = re.escape(function_name)
    func_name_pattern = re.compile(es_function_name)

    temp_not_contain = "\s*" + not_contain + "\s+"
    not_contain_pattern = re.compile(temp_not_contain)

    with open(file_name, 'r') as openfile:
        for num,line in enumerate(openfile):

            logging.debug("Current line is :" + line)

            if func_name_pattern.findall(line):
                logging.debug("FIND function" + function_name)
                find_status = 1

            if find_status == 1:
                logging.debug("Start to store function content")
                if not re.search(r'^\s+$', line) and not re.search(r'^\s*#+.*',line):  # ignore blank line and commented line.
                    if re.search(r'\{', line):
                        count_left_bracket = count_left_bracket + 1

                    if re.search(r'\}', line):
                        count_right_bracket = count_right_bracket + 1

                    function_content.append(line)  # Store the function content.
                    if count_left_bracket != 0 and count_left_bracket == count_right_bracket:  # if the "{" and "}" is paired. That means the fuction definition is done. Record the status.
                        function_end = 1

                    if function_end == 1:
                        for i in function_content:  # Search in the stored content.
                            if not_contain_pattern.findall(i):
                                logging.error("SE0003: in script: " + file_name + ": function: " + function_name + " should NOT contain " + not_contain)  # need to testing again.
            if function_end == 1:
                logging.debug("Should break")
                break


def check_func_contain (file_name, function_name, should_contain ):

    function_end = 0
    function_content = []
    count_left_bracket = 0
    count_right_bracket = 0
    final_result=0
    find_status=0

    es_function_name=re.escape(function_name)
    func_name_pattern = re.compile(es_function_name)

    temp_should_contain= "\s*"+should_contain+"\s+"
    should_contain_pattern = re.compile(temp_should_contain)


    with open(file_name, 'r') as openfile:
        for num,line in enumerate(openfile):

            logging.debug ("Current line is :"+line)

            if func_name_pattern.findall(line):
                logging.debug ("FIND function"+ function_name)
                find_status=1

            if find_status==1:
                logging.debug ("Start to store function content")
                if not re.search(r'^\s+$', line) and not re.search(r'^\s*#+.*', line):  #ignore blank line and commented line.
                    if re.search(r'\{', line):
                        count_left_bracket = count_left_bracket +1

                    if re.search(r'\}', line):
                        count_right_bracket = count_right_bracket +1

                    function_content.append(line)       #Store the function content.
                    if count_left_bracket != 0 and count_left_bracket == count_right_bracket :      #if the "{" and "}" is paired. That means the fuction definition is done. Record the status.
                        function_end=1

                    if function_end == 1:

                        for i in function_content:  #Search in the stored content.

                            if should_contain_pattern.findall(i):
                                final_result=1

                        if final_result ==1:
                            pass

                        else:
                            logging.error ("SE0004: in script: " + tempfile + ": function: " + function_name + " should contain " + should_contain)  #need to testing again.
            if function_end == 1:
                logging.debug("Should break")
                break






def check_special_character(tempfile): #Special character, e.g. ':', should be quoted in "".

    #METACHARS = r'.^$*+?{}[]\|()'
    METACHARS = r'^*?\\:'     #Check list for special character.
    print_status=0
    quot_status =0
    quot_location=0

    with open(tempfile, 'r') as openfile:
        for num,line in enumerate(openfile):

            if quot_status == 1:
                if re.search(r'\"', line) and not re.search(r'\\\"', line):     #If find right quote, reset quot_staus and print_status.
                    print_status = 0
                    for i, c in enumerate(line):
                        if "\"" == c:
                            quot_location = i   #record the location of right quote. e.g.: printf "ab
                                                #                                                 c:cde",abc:def



            if (re.search(r'\s*echo.*', line) or re.search(r'\s*print.*', line)) and print_status !=1:  #Checking whether it's print information.
                print_status = 1

            if print_status == 1:
                if re.search(r'\"', line) and quot_status !=1:   #If find quto, set the status to 1.
                    quot_status =1
                    if re.search(r'\".*\"', line):      #If we find right quto in the same line reset the status, and continue to check next line. e.g.: printf "abc"
                        print_status = 0
                        quot_status = 0
                        rule = "\".*\""
                        rule = re.compile(rule)
                        temp = rule.findall(line)
                        templine = line.replace(temp[0], '', 1)     #replace the pirnt information with null. e.g. printf "abc:abc", abc:abc -> printf , abc:abc
                        for i, c in enumerate(templine):        #check special characters in left part.
                            if c in METACHARS:
                                tempchars = re.escape(c)
                                tempchars4 = "\".*" + tempchars + ".*\""
                                tempchars4 = re.compile(tempchars4)
                                if not tempchars4.findall(templine):
                                    #striped_line = line.strip("\n")
                                    logging.error("SE0005: in script: " + tempfile+" special character: \"" + c + "\" line %d: %r should be quoted in \"\"." %(num,line))
                        continue
            if print_status ==0:    #Only check the special character in non print information.
                for i, c in enumerate(line):
                    if i > quot_location:   #Start to search special character after right quote.
                        if c in METACHARS :
                            tempchars = re.escape(c)
                            tempchars1 = "#.*" + tempchars + ".*"
                            tempchars1 = re.compile(tempchars1)     #pattern for commented part contain special character e.g.: #abc:abc

                            tempchars2 = ".*" + tempchars + ".*#"
                            tempchars2 = re.compile(tempchars2)     #pattern for uncommented part contain special character e.g.: abc:abc#cde:cde

                            tempchars3 = "\".*" + tempchars + ".*\""
                            tempchars3 = re.compile(tempchars3)     #pattern for special character in quoted.

                            if tempchars1.findall(line):       # check whether this line has commented content
                                if tempchars2.findall(line):   # check whether the uncommented part of this line has the special character
                                    if not tempchars3.findall(line):
                                        logging.error("SE0005: in script: " + tempfile + " special character: \"" + c + "\" line %d: %r should be quoted in \"\"." % (num, line))
                            else:
                                if not tempchars3.findall(line) :
                                    #striped_line = line.strip("\n")
                                    logging.error("SE0005 in script: " + tempfile + " special character: \"" + c + "\" line %d: %r should be quoted in \"\"." % (num, line))
                quot_location = 0



def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hv", ["version", "help"])
    except getopt.error, msg:
        print msg
        print ("for help use --help or -h")
        sys.exit(2)
    if  args == [] and opts == []:
        usage()
        sys.exit()

    for op,value in opts:
        if op=="-h" or op=="--help":
            usage()
            sys.exit()
        elif op=="-s":
            second_file=value
        elif op=="--version" or op == "-v":
            version()
            sys.exit()
        else:
            usage()
            sys.exit()


    if args != []:
        logger.info('Start checking')
        for tempfile in args:
            check_cp(tempfile)
            check_variable_brace(tempfile)
            check_exit_return(tempfile)
            check_special_character(tempfile)

    logging.info("Checking is done.")


if __name__=="__main__":
    main()





