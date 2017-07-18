def check_func_not_contain (file_name, function_name, not_contain = ""):
    openfile = open(file_name)
    find_function = 0
    functiong_end = 0
    function_content = []
    count_left_bracket = 0
    count_right_bracket = 0
    final_result = 0

    func_name_pattern = re.compile(function_name)
    not_contain_pattern = re.compile(not_contain)

    print ("Start to find")
    for line in openfile.readlines():

        if find_function != 1:
            pass
        else:
            print ("Start to find func content")
            print ("The line is "+line)
            if not re.search(r'^\s+', line) and not re.search(r'^\s*#+.*', line):
                print ("Start to find {}")
                if re.search(r'\{', line):
                    print ("Find {")
                    count_left_bracket = count_left_bracket +1

                    print  ("count_left_bracket is %d" % (count_left_bracket))

                if re.search(r'\}', line):
                    print ("Find }")
                    count_right_bracket = count_right_bracket +1

                    print  ("count_right_bracket is %d" %(count_right_bracket))
                function_content.append(line)
                if count_left_bracket == count_right_bracket :
                    functiong_end=1
                    print ("Function is end")

                if functiong_end == 1:
                    print ("Start to find "+not_contain)
                    print (function_content)
                    for i in function_content:
                        if not_contain_pattern.findall(i):
                            final_result = 1
                    if final_result != 1:
                        pass
                        break
                    else:
                        print ("ERROR: " + file_name + ":function:" + function_name + "should not contain " + not_contain)
                        break

        if func_name_pattern.findall(line):
            find_function=1
            print ("Find it")


def check_func_contain (file_name, function_name, should_contain = ""):
    openfile = open(file_name)
    find_function = 0
    functiong_end = 0
    function_content = []
    count_left_bracket = 0
    count_right_bracket = 0
    final_result = 0

    func_name_pattern = re.compile(function_name)
    should_contain_pattern = re.compile(should_contain)

    print ("Start to find")
    for line in openfile.readlines():

        if find_function != 1:
            pass
        else:
            print ("Start to find func content")
            print ("The line is "+line)
            if not re.search(r'^\s+', line) and not re.search(r'^\s*#+.*', line):
                print ("Start to find {}")
                if re.search(r'\{', line):
                    print ("Find {")
                    count_left_bracket = count_left_bracket +1

                    print  ("count_left_bracket is %d" % (count_left_bracket))

                if re.search(r'\}', line):
                    print ("Find }")
                    count_right_bracket = count_right_bracket +1

                    print  ("count_right_bracket is %d" %(count_right_bracket))
                function_content.append(line)
                if count_left_bracket == count_right_bracket :
                    functiong_end=1
                    print ("Function is end")

                if functiong_end == 1:
                    print ("Start to find "+should_contain)
                    print (function_content)
                    for i in function_content:
                        if should_contain_pattern.findall(i):
                            final_result = 1
                    if final_result == 1:
                        pass
                        break
                    else:
                        print ("ERROR: " + file_name + ":function:" + function_name + "should contain " + should_contain)
                        break

        if func_name_pattern.findall(line):
            find_function=1
            print ("Find it")