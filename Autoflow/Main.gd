extends Control


const config= preload("res://config.gd")
var config_obj=config.new()

var TL_files=[]   ## 翻译库文件的集合
var TL_entrys=[]  ## 合并后的翻译词条对的数组

var is_test=true

func _ready():
    ## 开始相关测试监测
    print("当前项目路径：",G.dir_current_parent())
    $ButtonA.connect("button_down",self,"__on_merge_button_down")
    is_test=config_obj.TL_flow_objs_init()
    


## 文档合并按钮按下后，开始执行合并操作。
func __on_merge_button_down():
    print("执行文档合并")
    if is_test==false:
        print("格式检查没有通过，请修正。")
    else:
        for i in config_obj.TL_flow_objs:
            config_obj.TL_flow_obj_merge(i)
    pass










