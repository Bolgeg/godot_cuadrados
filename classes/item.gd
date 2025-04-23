class_name Item
extends RefCounted

var type_index:=0
var quantity:=0

func _init(type_index_to_set:int,quantity_to_set:int):
	type_index=type_index_to_set
	quantity=quantity_to_set

static func create(type_name:String,quantity_to_set:int)->Item:
	return new(Globals.get_item_type(type_name).index,quantity_to_set)

static func create_empty()->Item:
	return new(0,0)

func duplicate()->Item:
	return new(type_index,quantity)

func swap(item:Item):
	var type_index_copy=type_index
	var quantity_copy=quantity
	type_index=item.type_index
	quantity=item.quantity
	item.type_index=type_index_copy
	item.quantity=quantity_copy

func is_empty()->bool:
	return quantity==0

func has_block()->bool:
	return type_index<Globals.block_types.size()

func get_block()->Block:
	assert(type_index<Globals.block_types.size(),"Tried to get block version of item that has no block version")
	return Block.new(type_index)

func get_item_type()->ItemType:
	assert(type_index<Globals.item_types.size(),"Tried to get an item type out of bounds")
	return Globals.item_types[type_index]

func get_tool_speed()->float:
	if is_empty():
		return 1
	if has_block():
		return 1
	return get_item_type().tool_speed
