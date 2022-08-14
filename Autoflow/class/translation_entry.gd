## 原文
var source_text:String

## 译文
var translation_text:String

func _init(source_text:String,translation_text:String):
    self.source_text=source_text
    self.translation_text=translation_text

func _to_string():
    return "原文：\n"+source_text +"\n译文：\n"+translation_text
