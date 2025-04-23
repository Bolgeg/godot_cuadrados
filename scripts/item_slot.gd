extends Control

var index:=0
var item_movable:=false

signal mouse_clicked_to_move(item_slot_index:int)

func _ready() -> void:
	%ToolbarOutline.visible=false

func set_toolbar_outline(show_outline:bool):
	%ToolbarOutline.visible=show_outline

func set_item(item:Item):
	%ItemScene.set_item(item)

func set_as_movable(index_to_set:int):
	item_movable=true
	index=index_to_set

func _process(_delta: float) -> void:
	var color:=Color8(128,128,128,192)
	var mouse_hover:=false
	if item_movable:
		if Rect2(global_position,size).has_point(get_viewport().get_mouse_position()):
			mouse_hover=true
			color=Color8(192,192,192,192)
	%BackgroundPanel.get_theme_stylebox("panel").bg_color=color
	if item_movable and mouse_hover:
		if Input.is_action_just_pressed("mouse_click"):
			mouse_clicked_to_move.emit(index)
