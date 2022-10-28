extends Node

var translationLibrary_path=G.dir_current_parent()+"/TranslationLibrary/"
var targetDoc_path=G.dir_current_parent()+"TargetDoc/"

const TL_file= preload("res://class/translation_library_file.gd")

## 翻译流字典对象
var TL_flow_objs=[
    {"源文件名称":"manual/manual20220922.md",
    "词条文件":["manual/manual_1.md","manual/manual_2.md","manual/manual_3.md","manual/manual_4.md","manual/manual_5.md","manual/manual_6.md","manual/manual_7.md",
    "manual/manual_8.md","manual/manual_9.md","manual/manual_patch.md","manual/manual_pathch20220922.md"],
    "目标文件名称":"manual/manual.md",
    "目标遗留文件文件名称":"manual/manual_residue.md",
    "翻译词条":null,       ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"非精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    },
    
    {"源文件名称":"manual/sets_fragment20220922.txt",
    "词条文件":["manual/sets_fragment_1.txt","manual/sets_fragment_pathch20220922.txt"],
    "目标文件名称":"manual/sets_fragment.txt",
    "目标遗留文件文件名称":"manual/sets_fragment_residue.txt",
    "翻译词条":null,  ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"非精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    },
    {"源文件名称":"manual/var_t_return20220922.md",
    "词条文件":["manual/var_t_return.md"],
    "目标文件名称":"manual/var_t_return.md",
    "目标遗留文件文件名称":"manual/var_t_return_residue.txt",
    "翻译词条":null,  ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"非精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    },
    {"源文件名称":"tut/tut1.md",
    "词条文件":["tut/tut1_cn.md"],
    "目标文件名称":"tut/tut1.md",
    "目标遗留文件文件名称":"tut/tut1_residue.txt",
    "翻译词条":null,  ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    },
    {"源文件名称":"tut/tut2.md",
    "词条文件":["tut/tut2_cn.md"],
    "目标文件名称":"tut/tut2.md",
    "目标遗留文件文件名称":"tut/tut2_residue.txt",
    "翻译词条":null,  ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    },
    {"源文件名称":"tut/tut3.md",
    "词条文件":["tut/tut3_cn.md"],
    "目标文件名称":"tut/tut3.md",
    "目标遗留文件文件名称":"tut/tut3_residue.txt",
    "翻译词条":null,  ## 该数组将在程序初始化时执行解析加载
    "翻译模式":"精确对比",   ## 翻译模式为精确对比时,词条文件中词条必须在全部存在
    }


   ]

## 对翻译对象组进行初始化
func TL_flow_objs_init():
    var is_pass=true
    for i in TL_flow_objs: ## 迭代每个工作流对象
        var TL_entrys=[]   ## 翻译词条
        for p in i["词条文件"]:
            var _content=G.load_file(translationLibrary_path+p)
            var _TL_files=TL_file.new(_content,p,translationLibrary_path)
            var mark_num=_TL_files.count_Add_Mark()
            
            if mark_num % 3 ==0:
                print(_TL_files.file_name+"文件标记3整除余数检查通过。","词条数为:",mark_num/3)
            else:
                print(_TL_files.file_name+"文件标记3整除余数检查失败。","余数为:",mark_num % 3)
                return false ## 基本验证未通过，则初始化失败
            pass
            
            TL_entrys.append_array(_TL_files.get_TL_entrys())
        
        i["翻译词条"]=TL_entrys
        TL_flow_obj_sorting_by_length(i) ## 按长度执行一次排序
        
        if i["翻译词条"].size()>0:
            #print("对第一个翻译词条字符串打印测试：",i["翻译词条"][0])
            pass
            
        if TL_flow_obj_in_test(i)==false:
            print(i["源文件名称"],"反包含验证失败了。")
            return false
        else:
            print(i["源文件名称"],"反包含验证成功。")
        
        print(i["源文件名称"],"当前所提取到的翻译词条数量为:",TL_entrys.size())
        if i["翻译模式"]=="精确对比":
            is_pass= TL_flow_obj_test(i)
            print(i["源文件名称"],"词条存在性验证结果",is_pass)
            pass
    
    return is_pass  ## 返回验证结果


## 对翻译词条的原文进行是否存在性监测
func TL_flow_obj_test(TL_flow_obj):
    var tar_doc_file:String=G.load_file(targetDoc_path+TL_flow_obj["源文件名称"])
    var is_pass=true
    for i in TL_flow_obj["翻译词条"]:
        if tar_doc_file.find(i.source_text)==-1 :
            print("以下是未检测发现不存的原文词条")
            print(i.source_text)
            is_pass=false
        pass
    return is_pass   ## 返回验证结果


## 对字符翻译数组按字符串长度进行一次排序。
func TL_flow_obj_sorting_by_length(TL_flow_obj):
    var _TLL=TL_flow_obj["翻译词条"]
    for i in range(_TLL.size()):
        for u in range(i,_TLL.size()):
            if _TLL[u].source_text.length()>_TLL[i].source_text.length():
                var c=_TLL[i]
                _TLL[i]=_TLL[u]
                _TLL[u]=c


## 验证词条的反包含性,即验证较短词条是否重复替代较长词条翻译后的结果。
func TL_flow_obj_in_test(TL_flow_obj):
    var _TLL=TL_flow_obj["翻译词条"]
    var length=_TLL.size()-1
    if length==-1:
        return true
        
    var is_pass=true
    while length>=0:
        for u in range(length):
            if _TLL[u].translation_text.find(_TLL[length].source_text)!=-1:
                is_pass=false
                print("该词条反包含：\n",_TLL[length].source_text)
            pass
        length-=1
    return is_pass


func TL_flow_obj_merge(TL_flow_obj):
    
    var tar_doc_file:String=G.load_file(targetDoc_path+TL_flow_obj["源文件名称"])
    var tar_doc_file_copy=tar_doc_file
    
    for i in TL_flow_obj["翻译词条"]:
        tar_doc_file=tar_doc_file.replace(i.source_text,i.translation_text)
        pass
    for i in TL_flow_obj["翻译词条"]:
        tar_doc_file_copy=tar_doc_file_copy.replace(i.source_text,"{==+==}")
        pass
    G.save_file(tar_doc_file,G.dir_current_parent()+"products/"+TL_flow_obj["目标文件名称"])
    G.save_file(tar_doc_file_copy,G.dir_current_parent()+"products/"+TL_flow_obj["目标遗留文件文件名称"])
    




















