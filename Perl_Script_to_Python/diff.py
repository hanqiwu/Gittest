import sys,getopt
opts, args = getopt.getopt(sys.argv[1:],"hf:s:", ["version"])
first_file=""
second_file=""
def usage():
    print ("Usage:Compare the difference.\n")
    print (sys.argv[0]+" -f first_file_name -s second_file_name")
def version():
    print "Original version."
print (opts)
print (args)

for op,value in opts:
    if op=="-f":
        first_file=value
    elif op=="-s":
        second_file=value
    elif op=="-h":
        usage()
        sys.exit()
    elif op=="--version":
        version()
#    else:
#        usage()
#       sys.exit()

if  args != [] and opts != []:
    for file in args:
        print ("OK")
else:
    usage()
    sys.exit()


ff=[]
ss=[]

firstfile = open(first_file)
#flines = firstfile.readlines()

for line in firstfile.readlines():
    temp=line.strip()
    ff.append(temp)

secondfile = open(second_file)
#slines = secondfile.readlines()

for line in secondfile.readlines():
    temp=line.strip()
    ss.append(temp)

ftos=[]

for i in ff:
    if i not in ss:
        ftos.append(i)

stof=[]

for i in ss:
    if i not in ff:
        stof.append(i)

print ("Compare first file to second file, the missing part is:")
print (ftos)

print ("Compare second file to first file, the missing part is:")
print (stof)





