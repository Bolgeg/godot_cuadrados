class_name CraftingRecipe
extends RefCounted

var result:=Item.create_empty()
var ingredients:=[]

func _init(result_to_set:Item=Item.create_empty(),ingredients_to_set:Array=[]) -> void:
	result=result_to_set
	ingredients=ingredients_to_set
