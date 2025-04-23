extends Control

var item:Item=Item.create_empty()

func _ready() -> void:
	update_visualization()

func set_item(item_to_set:Item):
	item=item_to_set.duplicate()
	update_visualization()

func update_visualization():
	if item.quantity==0:
		%Texture.visible=false
		%QuantityLabel.text=""
	else:
		%Texture.visible=true
		var index:=0
		if item.type_index<Globals.block_types.size():
			%Texture.texture.atlas=preload("res://assets/tiles.png")
			index=item.type_index
		else:
			%Texture.texture.atlas=preload("res://assets/items.png")
			index=item.type_index-Globals.block_types.size()
		var tex_x:int=%Texture.texture.atlas.get_size().x/Cell.SIZE
		@warning_ignore("integer_division")
		var offset=Vector2i(index%tex_x,index/tex_x)*Cell.SIZE
		%Texture.texture.region.position=Vector2(offset)
		
		if item.quantity==1:
			%QuantityLabel.text=""
		else:
			%QuantityLabel.text=str(item.quantity)
