extends Node2D

const CAMERA_RECT_MAX_OFFSET_OUTSIDE:=100

var world_seed:=0
var chunks:={}

func create_chunk(location:Vector2i):
	if not chunks.has(location):
		chunks[location]=Chunk.new(location)
		WorldGeneration.generate_chunk(chunks[location],world_seed)

func get_camera_rect()->Rect2i:
	var center=Vector2i(%Camera2D.get_screen_center_position())
	var size=get_viewport().size
	return Rect2i(center-size/2,size)

func get_visible_chunk_locations()->Array:
	var rect:=get_camera_rect()
	var chunk_size:=Chunk.SIZE*Cell.SIZE
	@warning_ignore("integer_division")
	rect=rect.grow(CAMERA_RECT_MAX_OFFSET_OUTSIDE+chunk_size/2)
	rect=Rect2i(rect.position-Vector2i(chunk_size,chunk_size)/2,rect.size)
	rect=Rect2i((Vector2(rect.position)/chunk_size).floor(),(Vector2(rect.size)/chunk_size).ceil())
	
	var positions=[]
	for y in range(rect.position.y,rect.end.y+1):
		for x in range(rect.position.x,rect.end.x+1):
			positions.append(Vector2i(x,y))
	return positions

func update_chunk_loading():
	var chunk_locations=get_visible_chunk_locations()
	
	for location in chunk_locations:
		create_chunk(location)
		%CellMap.put_chunk(chunks[location])
	
	for location in chunks:
		if not location in chunk_locations:
			%CellMap.remove_chunk(location)
	
	for location in chunk_locations:
		var relative_locations=[Vector2i(0,-1),Vector2i(0,1),Vector2i(-1,0),Vector2i(1,0)]
		var c=[]
		for rel in relative_locations:
			var loc=location+rel
			if chunks.has(loc):
				c.append(chunks[loc])
			else:
				c.append(null)
		%CellMap.update_chunk(32,chunks[location],c[0],c[1],c[2],c[3])

func _ready() -> void:
	update_chunk_loading()

func _process(_delta: float) -> void:
	update_chunk_loading()
