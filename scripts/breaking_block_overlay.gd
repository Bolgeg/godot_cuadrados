extends Node2D

func update_state(progress:float):
	var texture:Texture2D=%Sprite2D.texture
	var tex_size:=Vector2i(texture.get_size())
	@warning_ignore("integer_division")
	var tex_positions=tex_size.x/tex_size.y
	var tex_position:=int(floor(progress*tex_positions))
	if tex_position<0:
		tex_position=0
	elif tex_position>=tex_positions:
		tex_position=tex_positions-1
	%Sprite2D.region_rect.position.x=tex_position*tex_size.y
