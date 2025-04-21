class_name CellMapChunk
extends Node2D

const SIZE:=Chunk.SIZE

class CellData extends RefCounted:
	var changed:=true
	
	var texture_index:=0:
		set(value):
			if value!=texture_index:
				texture_index=value
				changed=true
	var borders:=[false,false,false,false]:
		set(value):
			if value!=borders:
				borders=value
				changed=true
	var overlay_color:=Color(1,1,1,0):
		set(value):
			if value!=overlay_color:
				overlay_color=value
				changed=true
	var collision:=0:
		set(value):
			if value!=collision:
				collision=value
				changed=true

var location:=Vector2i(0,0)
var cells:=[]

func set_location(location_to_set:Vector2i):
	location=location_to_set
	position=Vector2(location*SIZE*Cell.SIZE)

func _init() -> void:
	for i in range(SIZE*SIZE):
		cells.append(CellData.new())

func _ready() -> void:
	var cell_node_model=preload("res://scenes/cell.tscn")
	for i in range(SIZE*SIZE):
		var cell_node=cell_node_model.instantiate()
		add_child(cell_node)
		@warning_ignore("integer_division")
		cell_node.set_location(i%SIZE,i/SIZE)

func _physics_process(_delta: float) -> void:
	update_children()

func update_children():
	for cell:Cell in get_children():
		var index:int=cell.relative_location.y*SIZE+cell.relative_location.x
		var cell_data:CellData=cells[index]
		if cell_data.changed:
			cell.set_texture(cell_data.texture_index)
			cell.set_borders(cell_data.borders[0],cell_data.borders[1],cell_data.borders[2],cell_data.borders[3])
			cell.set_overlay(cell_data.overlay_color)
			cell.set_collision(cell_data.collision)
			cell_data.changed=false

func cell_at(x:int,y:int)->CellData:
	return cells[y*SIZE+x]

static func overlay_color_function(x:int):
	return 1-exp(-float(x)*0.25)

static func calculate_overlay_color(relative_height:int)->Color:
	if relative_height==0:
		return Color(0,0,0,0)
	elif relative_height>0:
		return Color(0,0,0,overlay_color_function(relative_height))
	else:
		return Color(1,1,1,overlay_color_function(-relative_height))

static func calculate_collision_mask(height:int)->int:
	var mask:=0
	if height<32:
		mask|=(1<<height)
	if height>0:
		mask|=(1<<(height-1))
	if height<31:
		mask|=(1<<(height+1))
	mask=~mask
	return mask

func update(player_height:int,chunk:Chunk,chunk_up:Chunk,chunk_down:Chunk,chunk_left:Chunk,chunk_right:Chunk):
	for y in range(SIZE):
		for x in range(SIZE):
			var cell:=cell_at(x,y)
			var column=chunk.column_at(x,y)
			var height=column.get_height()
			cell.collision= calculate_collision_mask(height)
			cell.texture_index=column.get_top_block().type_index
			cell.overlay_color=calculate_overlay_color(height-player_height)
			
			var borders=[false,false,false,false]
			for side in [
				{
					"index":0,
					"rx":0,
					"ry":-1,
					"chunk":chunk_up,
					"condition":y>0,
				},
				{
					"index":1,
					"rx":0,
					"ry":1,
					"chunk":chunk_down,
					"condition":y<Chunk.SIZE-1,
				},
				{
					"index":2,
					"rx":-1,
					"ry":0,
					"chunk":chunk_left,
					"condition":x>0,
				},
				{
					"index":3,
					"rx":1,
					"ry":0,
					"chunk":chunk_right,
					"condition":x<Chunk.SIZE-1,
				},
			]:
				var c= chunk if side.condition else side.chunk
				if c==null:
					borders[side.index]=true
				else:
					borders[side.index]= c.column_at(x+side.rx,y+side.ry).get_height()>height
			cell.borders=borders
