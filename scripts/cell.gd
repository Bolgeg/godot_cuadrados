class_name Cell
extends Node2D

const SIZE:=32

var relative_location:=Vector2i(0,0)

func set_location(relative_x:int,relative_y:int):
	relative_location=Vector2i(relative_x,relative_y)
	position=Vector2(relative_location*SIZE)

func set_texture(texture_index:int):
	var tex:Texture2D=%Texture.texture
	@warning_ignore("integer_division")
	var tex_size_x:int=int(tex.get_size().x)/SIZE
	var tex_x:int=texture_index%tex_size_x
	@warning_ignore("integer_division")
	var tex_y:int=texture_index/tex_size_x
	%Texture.region_rect.position.x=tex_x*SIZE
	%Texture.region_rect.position.y=tex_y*SIZE

func set_borders(up:bool,down:bool,left:bool,right:bool):
	%BorderUp.visible=up
	%BorderDown.visible=down
	%BorderLeft.visible=left
	%BorderRight.visible=right

func set_overlay(color:Color):
	%Overlay.color=color

func set_collision(collision_mask:int):
	%StaticBody2D.collision_mask=collision_mask
