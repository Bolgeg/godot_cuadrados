extends Node

var block_types:=[]
var block_types_dict:={}

var item_types:=[]
var item_types_dict:={}

func _ready() -> void:
	add_block_type("grass",1)
	add_block_type("dirt",1)
	add_block_type("stone",10)
	add_block_type("leaves",1)
	add_block_type("log",1)
	add_block_type("copper_ore",10)
	add_block_type("hard_stone",100)
	add_block_type("tin_ore",10)
	add_block_type("iron_ore",100)
	add_block_type("wood",1)
	add_block_type("stone_bricks",10)
	
	add_block_item_types()
	
	#TODO add item types here

func get_base_block_type_name()->String:
	return "stone"

func add_block_item_types():
	for block_type in block_types:
		add_item_type(block_type.type_name)

func add_block_type(type_name:String,time_to_break:float):
	assert(not block_types_dict.has(type_name),"Block type already exists with name: "+type_name)
	var block_type=BlockType.new(block_types.size(),type_name,time_to_break)
	block_types.append(block_type)
	block_types_dict[type_name]=block_type

func add_item_type(type_name:String):
	assert(not item_types_dict.has(type_name),"Item type already exists with name: "+type_name)
	var item_type=ItemType.new(item_types.size(),type_name)
	item_types.append(item_type)
	item_types_dict[type_name]=item_type

func get_block_type(type_name:String):
	assert(block_types_dict.has(type_name),"Block type not found: "+type_name)
	return block_types_dict[type_name]

func get_item_type(type_name:String):
	assert(item_types_dict.has(type_name),"Item type not found: "+type_name)
	return item_types_dict[type_name]
