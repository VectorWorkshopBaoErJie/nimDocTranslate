var content:String      ## 内容
var file_name:String    ## 文件名称
var file_path:String    ## 所在目录

const TL_entry= preload("res://class/translation_entry.gd")
var TL_entrys=[] 

func _init(content:String,file_name:String,file_path:String):
    self.content=content
    self.file_name=file_name
    self.file_path=file_path

func _to_string():
    return "正文:"+content+" 文件名:"+file_name+" 目录:"+file_path

## 统计添加标记数量
func count_Add_Mark():
    var regex = RegEx.new()
    regex.compile("\\{==\\+==\\}")
    var result = regex.search_all(content)
    return result.size()
#    if result:
#        print(result.get_string()) # 会输出 n-0123

## 获得翻译词条
func get_TL_entrys():
    var regex = RegEx.new()
    regex.compile("\\{==\\+==\\}\\n(?<source>[\\s\\S]*?)\\n\\{==\\+==\\}\\n(?<translation>[\\s\\S]*?)\\n\\{==\\+==\\}")
    var results = regex.search_all(content)
    for i in results:
        var tl_entry=TL_entry.new(i.get_string("source"),i.get_string("translation"))
        TL_entrys.append(tl_entry)
        pass
    return TL_entrys

