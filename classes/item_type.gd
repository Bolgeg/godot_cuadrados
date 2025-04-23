class_name ItemType
extends RefCounted

var index:=0
var type_name:=""
var tool_speed:=1.0

func _init(index_to_set:int,type_name_to_set:String) -> void:
	index=index_to_set
	type_name=type_name_to_set
