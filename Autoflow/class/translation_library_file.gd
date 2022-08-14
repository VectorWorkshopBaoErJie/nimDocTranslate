extends Node

var content:String      ## 内容
var file_name:String    ## 文件名称
var file_path:String    ## 所在目录

func _init(content:String,file_name:String,file_path:String):
    self.content=content
    self.file_name=file_name
    self.file_path=file_path

func _to_string():
    return "正文:"+content+" 文件名："+file_name+" 目录："+file_path
    
func count_Add_Mark():
    var regex = RegEx.new()
    regex.compile("\\{==\\+==\\}")
    var result = regex.search_all(content)
    return result.size()
#    if result:
#        print(result.get_string()) # 会输出 n-0123

