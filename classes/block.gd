class_name Block
extends RefCounted

var type_index:=0

func _init(type_index_to_set:int):
	type_index=type_index_to_set

static func create(type_name:String):
	return new(Globals.get_block_type(type_name).index)

func set_type(type_name:String):
	type_index=Globals.get_block_type(type_name).index
