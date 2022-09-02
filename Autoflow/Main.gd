extends Control

var translationLibrary_path=G.dir_current_parent()+"/TranslationLibrary/"
var targetDoc_path=G.dir_current_parent()+"TargetDoc/"

const TL_file= preload("res://class/translation_library_file.gd")

var TL_files=[]   ## 翻译库文件的集合
var TL_entrys=[]  ## 合并后的翻译词条对的数组

var is_test=true

func _ready():
    ## 开始相关测试监测
    $ButtonA.connect("button_down",self,"__on_merge_button_down")
    $ButtonB.connect("button_down",self,"__on_merge_null_button_down")
    test()
#    sorting_by_length()
#
#    for i in TL_entrys:
#        print(i.source_text.length())
#        pass
    

func test():
    ## 读取翻译库文档
    var all_files=[] ## 文档数组
    G.dir_contents(translationLibrary_path,all_files) ## 遍历到所有文件
    for i in all_files:
        var content=G.load_file(i["目录"]+i["文件"])
        TL_files.append(TL_file.new(content,i["文件"],i["目录"]))

    ## 对翻译库的文档进行标记格式验证。
    for i in TL_files:
        var mark_num=i.count_Add_Mark()
        if mark_num % 3 ==0:
            print(i.file_name+"文件标记3整除余数检查通过。")
        else:
            print(i.file_name+"文件标记3整除余数检查失败。","余数为:",mark_num % 3)
            is_test=false 
        pass
                
    ## 提取标记监测，提取为翻译词条对象，验证翻译词条
    for i in TL_files:
        TL_entrys.append_array(i.get_TL_entrys())
        pass
        
    print("当前所提取到的翻译词条数量为:",TL_entrys.size())
    ## 对翻译词条的原文进行是否存在性监测
    var tar_doc_file:String=G.load_file(targetDoc_path+"manual20220810.md")
    for i in TL_entrys:
        if tar_doc_file.find(i.source_text)==-1 :
            print("以下是未检测发现不存的原文词条")
            print(i.source_text)
            is_test=false 
        pass
    ## 注入后提取未翻译部分翻译库的补充翻译部分
    pass

## 文档合并按钮按下后，开始执行合并操作。
func __on_merge_button_down():
    print("执行文档合并")
    if is_test==false:
        print("格式检查没有通过，请修正。")
    else:
        var tar_doc_file:String=G.load_file(targetDoc_path+"manual20220810.md")
        ## 这里对翻译对按字符串的长度排序
        sorting_by_length()
        
        for i in TL_entrys:
            tar_doc_file=tar_doc_file.replace(i.source_text,i.translation_text)
            pass
        #print(tar_doc_file)
        G.save_file(tar_doc_file,G.dir_current_parent()+"products/manual.md")
    pass

## 按下执行按钮后，进行空替换操作，即对匹配到的字符串替换为一个空表示。
func __on_merge_null_button_down():
    print("执行遗留替换")
    if is_test==false:
        print("格式检查没有通过，请修正。")
    else:
        var tar_doc_file:String=G.load_file(targetDoc_path+"manual20220810.md")
        ## 这里对翻译对按字符串的长度排序
        sorting_by_length()
        
        for i in TL_entrys:
            tar_doc_file=tar_doc_file.replace(i.source_text,"{=====}")
            pass
        #print(tar_doc_file)
        G.save_file(tar_doc_file,G.dir_current_parent()+"products/manual_null.md")
    pass


## 对字符翻译数组按字符串长度进行一次排序。
func sorting_by_length():
    for i in range(TL_entrys.size()):
        for u in rand_range(i,TL_entrys.size()):
            if TL_entrys[u].source_text.length()<TL_entrys[i].source_text.length():
                var c=TL_entrys[i]
                TL_entrys[i]=TL_entrys[u]
                TL_entrys[u]=c
            pass






