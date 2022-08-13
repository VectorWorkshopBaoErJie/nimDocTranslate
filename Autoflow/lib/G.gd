extends Node

func dir_contents(path,files:Array):
    var dir = Directory.new()
    if dir.open(path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name=="." or file_name=="..":
                file_name = dir.get_next()
                continue;
            if dir.current_is_dir() :
                # print("发现目录：" + file_name)
                dir_contents(path+"/"+file_name,files)
            else:
                files.append({"目录":path,"文件":file_name})
                # print("发现文件：" + file_name)
            file_name = dir.get_next()
    else:
        print("尝试访问路径时出错。")


#func 按照逗号分隔出字符的前半部分(字符串:String,分隔符号):
#    if 字符串=="":
#        return ""
#    var 子串=字符串.split(分隔符号)
#    var 字符串B=""
#    if 子串.size()>1:
#        for 单元 in range(0,子串.size()-1):
#            字符串B+=子串[单元]
#    return 字符串B

func load_file(path):
    var file = File.new()
    file.open(path, File.READ)
    var content = file.get_as_text()
    file.close()
    return content


func save_file(content,path):
    var file = File.new()
    file.open(path, File.WRITE)
    file.store_string(content)
    file.close()

#class 翻译对:
#    var 原文:String
#    var 译文:String
    
## 文件路径 "res://目标目录/manual####/"+"manual__0.md"
## 匹配正则 "{=1=}\n(?<group>[\\s\\S]*?){=1=}\n"
#func 从文件中提取翻译对组(文件路径,分隔符号="{=2=}\n",匹配正则="{=1=}\n(?<group>[\\s\\S]*?){=1=}\n"):
#    var 翻译对组=[]
#    var 内容=G.load_file(文件路径)
#    #print(内容)
#    var regex = RegEx.new()
#    regex.compile(匹配正则)
#    var result = regex.search_all(内容)
#    for 单元 in result:
#        var 翻译对=G.翻译对.new()
#        var resA=单元.get_string("group")
#        var resb=resA.split(分隔符号)
#        翻译对.原文=resb[0]
#        翻译对.译文=resb[1]
#        翻译对组.append(翻译对)
#    return 翻译对组





