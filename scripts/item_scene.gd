extends Control

func set_item(item:Item):
	if item==null:
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
			index=Globals.block_types.size()+item.type_index
		var tex_x:int=%Texture.texture.atlas.get_size().x/Cell.SIZE
		@warning_ignore("integer_division")
		var offset=Vector2i(index%tex_x,index/tex_x)*Cell.SIZE
		%Texture.texture.atlas.region.position=offset
		
		if item.quantity==1:
			%QuantityLabel.text=""
		else:
			%QuantityLabel.text=str(item.quantity)
