class_name BlockType
extends RefCounted

var index:=0
var type_name:=""
var time_to_break:=1.0

func _init(index_to_set:int,type_name_to_set:String,time_to_break_to_set:float) -> void:
	index=index_to_set
	type_name=type_name_to_set
	time_to_break=time_to_break_to_set
