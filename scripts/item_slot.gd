extends Control

func _ready() -> void:
	%ToolbarOutline.visible=false

func set_toolbar_outline(show_outline:bool):
	%ToolbarOutline.visible=show_outline

func set_item(item:Item):
	%ItemScene.set_item(item)
