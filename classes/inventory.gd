class_name Inventory
extends RefCounted

const ROWS:=4
const COLUMNS:=9
const SIZE:=ROWS*COLUMNS

var items:=[]

func _init() -> void:
	for i in range(SIZE):
		items.append(Item.create_empty())

func add_item(item:Item)->bool:
	if item.quantity>0:
		for i:Item in items:
			if not i.is_empty():
				if i.type_index==item.type_index:
					i.quantity+=item.quantity
					return true
		for i in items.size():
			if items[i].is_empty():
				items[i]=item
				return true
		return false
	return true

func get_item_tool_speed(index:int)->float:
	assert(index>=0 and index<SIZE,"Trying to check item tool speed from inventory at an out of bounds index")
	return items[index].get_tool_speed()

func item_is_block(index:int)->bool:
	assert(index>=0 and index<SIZE,"Trying to check if item from inventory is block at an out of bounds index")
	if items[index].is_empty():
		return false
	if items[index].has_block():
		return true
	return false

func remove_item(index:int,quantity:int=1)->Item:
	assert(index>=0 and index<SIZE,"Trying to remove item from inventory at an out of bounds index")
	if items[index].is_empty():
		return Item.create_empty()
	if items[index].quantity<quantity:
		quantity=items[index].quantity
	var itemToReturn:=Item.new(items[index].type_index,quantity)
	items[index]=Item.new(items[index].type_index,items[index].quantity-quantity)
	if items[index].quantity==0:
		items[index]=Item.create_empty()
	return itemToReturn
