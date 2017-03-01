# -*- coding: GBK -*
# Author: Seay
# Blog :www.cnseay.com
 
import os,sys,re
 
findstr='';
 
def func_findstr(filepath):
    thefile=open(filepath, 'rb')
    while True:
        buffer = thefile.read(104857600)
        if not buffer:
            break
        for match in re.findall('\n.*'+findstr+'.*\n',buffer): 
            print "Found in "+filepath+" %s" % match
            print ''
    thefile.close()
 
def func_walks(path):
    for root, dirs, files in os.walk(path):
        for f in files:
            f = os.path.join(root, f)
            func_findstr(f)
 
def filterstr(str):
    str = str.replace('.','\.').replace('[','\[').replace(']','\]').replace('$','\$').replace('\\','\\\\')
    return str.replace('(','\(').replace(')','\)').replace('{','\{').replace('}','\}').replace('^','\^')
if __name__ == '__main__':
    if len(sys.argv)>=4 and (sys.argv[1]=='-f' or sys.argv[1]=='-d'):
        if sys.argv[1]=='-f' and os.path.isfile(sys.argv[2]):
            findstr = filterstr(sys.argv[3])
            func_findstr(sys.argv[2])
        elif sys.argv[1]=='-d' and os.path.exists(sys.argv[2]):
            findstr = filterstr(sys.argv[3])
            func_walks(sys.argv[2])
        else:
            print '-- ????'
    elif len(sys.argv)==2:
        findstr = filterstr(sys.argv[1])
        print func_walks(os.getcwd())
    else:
        print '-- ???? :'
        print '    1. '+sys.argv[0]+ ' -f' +' filename "string" \t?????????'
        print '    2. '+sys.argv[0]+ ' -d' +' directory "string" \t?????(?????)???????????'
        print '    3. '+sys.argv[0]+ ' "string" \t?????(?????)???????????'