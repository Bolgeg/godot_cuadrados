class_name Item
extends RefCounted

var type_index:=0
var quantity:=0

func _init(type_index_to_set:int,quantity_to_set:int):
	type_index=type_index_to_set
	quantity=quantity_to_set

static func create(type_name:String,quantity_to_set:int)->Item:
	return new(Globals.get_item_type(type_name).index,quantity_to_set)

func has_block()->bool:
	return type_index<Globals.block_types.size()

func get_block()->Block:
	assert(type_index<Globals.block_types.size(),"Tried to get block version of item that has no block version")
	return Block.new(type_index)
