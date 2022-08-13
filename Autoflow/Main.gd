extends Node2D

var translationLibrary_path="F:/develop/nimDocTranslate/TranslationLibrary/"
var targetDoc_path="F:/develop/nimDocTranslate/TargetDoc/"

const TL_file= preload("res://class/translation_library_file.gd")

var TL_files=[]

func _ready():
    ## 开始相关测试监测
    test()
    pass
    
func test():
    ## 读取翻译库文档
    var all_files=[] ## 文档数组
    G.dir_contents(translationLibrary_path,all_files) ## 遍历到所有文件
    for i in all_files:
        var content=G.load_file(i["目录"]+i["文件"])
        TL_files.append(TL_file.new(content,i["文件"],i["目录"]))
        pass
    
    print(TL_files)
    
    ## 对翻译库的文档进行标记格式验证。
    
    
    ## 提取标记监测，提取为翻译词条对象，验证翻译词条
    
    ## 对翻译词条的原文进行是否存在性监测
    
    ## 注入后提取未翻译部分翻译库的补充翻译部分
    
    ## 循环以上流程生成完整文档。
    
    ## 
    pass
