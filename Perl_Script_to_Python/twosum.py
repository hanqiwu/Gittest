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


def check_cp (openfile) : #'cp' command should be followed with arguments.
        position = openfile.tell()
        print ("Current position is:", position)

        for num,line in enumerate(openfile):

           if "cp " in line and not re.search(r'^\s*#.*', line):  #contain cp command and the line is not commented.
               check_result=re.search(r'cp\s+\-\S',line)    #check whether the cp command is followed with arguments.
               if check_result:
                    pass
               else:
                   #striped_line=line.strip("\n")
                   logger.error ("SE0001: in script: "+" line %d: %r :cp command should be followed with arguments." %(num,line))


def pre_check_file(openfile): #check whether the file is existed before access it.
    pass


def check_return_code(openfile): #Check command execute return code, if next operation depend on last command execution result.
    pass


def check_exit_code(openfile): #check last command result before doing next step if they have dependency.
    pass


def check_variable_brace(openfile):#use '${}' when using a variable
        position = openfile.tell()
        print ("Current position is:", position)
        position = openfile.seek(0, 0)
        print ("Current position is:", position)
        for num,line in enumerate(openfile):
           if "$" in line and not re.search(r'^\s*#.*', line):  #contain $ and the line is not commented.

              check_result=re.search(r'\$\{\S*\}',line)     #check whether use '${}' when using a variable
              if check_result:
                  pass
              else:
                  #striped_line = line.strip("\n")
                  logger.error ("SE0002: in script: "+" line %d: %r :should use '${}' when using a variable." %(num,line))


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
            openfile= open(tempfile, "r")
            check_cp(openfile)
            check_variable_brace(openfile)

    logging.info("Checking is done.")


if __name__=="__main__":
    main()









