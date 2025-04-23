extends Control

signal mouse_clicked_to_get_result(recipe_index:int)

var recipe:=CraftingRecipe.new()
var index:=0
var mouse_rect:=Rect2(0,0,0,0)

func _ready() -> void:
	update_visualization()

func set_recipe(recipe_to_set:CraftingRecipe,index_to_set:int):
	recipe=recipe_to_set
	index=index_to_set
	update_visualization()

func set_mouse_rect(mouse_rect_to_set:Rect2):
	mouse_rect=mouse_rect_to_set

func update_visualization():
	%ResultItemSlot.set_item(recipe.result)
	%ResultItemSlot.set_as_movable(0,mouse_rect)
	
	for child in %IngredientGridContainer.get_children():
		%IngredientGridContainer.remove_child(child)
	
	var item_slot_scene=preload("res://scenes/item_slot.tscn")
	for ingredient in recipe.ingredients:
		var item_slot=item_slot_scene.instantiate()
		item_slot.set_item(ingredient)
		%IngredientGridContainer.add_child(item_slot)

func _on_result_item_slot_mouse_clicked_to_move(_item_slot_index: int) -> void:
	mouse_clicked_to_get_result.emit(index)
