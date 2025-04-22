extends Control

var selected_item_index:=0

func _ready() -> void:
	var item_slot_scene=preload("res://scenes/item_slot.tscn")
	for i in range(%ToolbarGridContainer.columns):
		%ToolbarGridContainer.add_child(item_slot_scene.instantiate())
	set_items_as_empty()
	set_selected_item(0)

func set_items_as_empty():
	for child in %ToolbarGridContainer.get_children():
		child.set_item(null)

func set_selected_item(index:int):
	var children:=%ToolbarGridContainer.get_children()
	if index>=0 and index<children.size():
		selected_item_index=index
		for child in children:
			child.set_toolbar_outline(false)
		children[index].set_toolbar_outline(true)

func _input(_event: InputEvent) -> void:
	const ACTIONS:={
		"item_1":0,
		"item_2":1,
		"item_3":2,
		"item_4":3,
		"item_5":4,
		"item_6":5,
		"item_7":6,
		"item_8":7,
		"item_9":8,
	}
	for action in ACTIONS:
		if Input.is_action_just_pressed(action):
			set_selected_item(ACTIONS[action])
			break
