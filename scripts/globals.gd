extends Node

var block_types:=[]
var block_types_dict:={}

func _ready() -> void:
	add_block_type("grass")
	add_block_type("dirt")
	add_block_type("stone")

func get_base_block_type_name()->String:
	return "stone"

func add_block_type(type_name:String):
	assert(not block_types_dict.has(type_name),"Block type already exists with name: "+type_name)
	var block_type=BlockType.new(block_types.size(),type_name)
	block_types.append(block_type)
	block_types_dict[type_name]=block_type

func get_block_type(type_name:String):
	assert(block_types_dict.has(type_name),"Block type not found: "+type_name)
	return block_types_dict[type_name]
