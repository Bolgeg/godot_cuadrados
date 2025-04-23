extends Control

signal mouse_clicked_to_move_item(item_index:int)

func _ready() -> void:
	visible=false
	var item_slot_scene=preload("res://scenes/item_slot.tscn")
	%InventoryGridContainer.columns=Inventory.COLUMNS
	for i in range(%InventoryGridContainer.columns*Inventory.ROWS):
		%InventoryGridContainer.add_child(item_slot_scene.instantiate())
	initialize_items()

func initialize_items():
	for index_in_container in range(%InventoryGridContainer.get_child_count()):
		var child=%InventoryGridContainer.get_child(index_in_container)
		child.set_as_movable(container_to_inventory_index(index_in_container))
		child.mouse_clicked_to_move.connect(on_mouse_clicked_to_move)

func on_mouse_clicked_to_move(item_slot_index:int):
	if visible:
		mouse_clicked_to_move_item.emit(item_slot_index)

func container_to_inventory_index(index_in_container:int)->int:
	var index_in_inventory=index_in_container+Inventory.COLUMNS
	if index_in_inventory>=Inventory.SIZE:
		index_in_inventory-=Inventory.SIZE
	return index_in_inventory

func update_items(inventory:Inventory):
	for index_in_container in range(%InventoryGridContainer.get_child_count()):
		var child=%InventoryGridContainer.get_child(index_in_container)
		var index_in_inventory=container_to_inventory_index(index_in_container)
		child.set_item(inventory.items[index_in_inventory])

func update_mouse_item(item:Item):
	%MouseItem.set_item(item)
	%MouseItem.global_position=get_viewport().get_mouse_position()

func open():
	visible=true
	%CraftingPanel.visible=true
	%ChestPanel.visible=false

func open_chest():
	visible=true
	%CraftingPanel.visible=false
	%ChestPanel.visible=true

func close():
	visible=false
