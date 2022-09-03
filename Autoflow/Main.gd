extends Control


const config= preload("res://config.gd")
var config_obj=config.new()

var TL_files=[]   ## 翻译库文件的集合
var TL_entrys=[]  ## 合并后的翻译词条对的数组

var is_test=true

func _ready():
    ## 开始相关测试监测
    $ButtonA.connect("button_down",self,"__on_merge_button_down")
    $ButtonB.connect("button_down",self,"__on_merge_null_button_down")
    config_obj.TL_flow_objs_init()
    
    

## 文档合并按钮按下后，开始执行合并操作。
func __on_merge_button_down():
    print("执行文档合并")
    if is_test==false:
        print("格式检查没有通过，请修正。")
    else:
        var tar_doc_file:String=G.load_file(config.targetDoc_path+"manual20220810.md")

        
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
        var tar_doc_file:String=G.load_file(config.targetDoc_path+"manual20220810.md")

        for i in TL_entrys:
            tar_doc_file=tar_doc_file.replace(i.source_text,"{=====}")
            pass
        #print(tar_doc_file)
        G.save_file(tar_doc_file,G.dir_current_parent()+"products/manual_null.md")
    pass








