extends Node2D

const CAMERA_RECT_MAX_OFFSET_OUTSIDE:=50

const BLOCK_OUTLINE_MAX_DISTANCE:=5.0

var world_seed:=0
var chunks:={}

var block_outline_active:=false
var block_outline_location:=Vector2i(0,0)

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
		%CellMap.update_chunk(%Player.position_z,chunks[location],c[0],c[1],c[2],c[3])

static func get_sized_structure_location(unit_location:Vector2i,size:int)->Vector2i:
	var loc=unit_location/size
	if loc.x*size>unit_location.x:
		loc.x-=1
	if loc.y*size>unit_location.y:
		loc.y-=1
	return loc

static func get_cell_location(pixel:Vector2i)->Vector2i:
	return get_sized_structure_location(pixel,Cell.SIZE)

static func get_chunk_location(cell_location:Vector2i)->Vector2i:
	return get_sized_structure_location(cell_location,Chunk.SIZE)

func get_altitude_at(cell_location:Vector2i)->int:
	var chunk_location:=get_chunk_location(cell_location)
	if chunks.has(chunk_location):
		var chunk:Chunk=chunks[chunk_location]
		var cell_location_in_chunk=cell_location-chunk_location*Chunk.SIZE
		var column:=chunk.column_at(cell_location_in_chunk.x,cell_location_in_chunk.y)
		return column.get_height()
	return Chunk.MAX_HEIGHT

func initialize_player():
	const INITIAL_POSITION=Vector2i(0,0)
	%Player.global_position=(Vector2(INITIAL_POSITION)+Vector2(0.5,0.5)
		)*Cell.SIZE-Vector2(%Player.SIZE,%Player.SIZE)/2
	%Player.set_position_z(get_altitude_at(INITIAL_POSITION))

func get_cell_location_from_screen_position(screen_position:Vector2i)->Vector2i:
	var position_absolute=get_camera_rect().position+screen_position
	return get_cell_location(position_absolute)

func update_block_outline(delta:float):
	var cell_location=get_cell_location_from_screen_position(get_viewport().get_mouse_position())
	if (cell_location-get_cell_location(%Player.global_position.floor())).length()<=BLOCK_OUTLINE_MAX_DISTANCE:
		block_outline_active=true
		block_outline_location=cell_location
	else:
		block_outline_active=false
	
	if block_outline_active:
		%BlockOutline.visible=true
		%BlockOutline.global_position=block_outline_location*Cell.SIZE
	else:
		%BlockOutline.visible=false
	
	if block_outline_active:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			try_to_break_block_progress(block_outline_location,delta)
		else:
			try_to_break_block_stop()
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				try_to_put_block_progress(block_outline_location,delta)
			else:
				try_to_put_block_stop()

func try_to_break_block_progress(location:Vector2i,delta:float):
	pass

func try_to_break_block_stop():
	pass

func try_to_put_block_progress(location:Vector2i,delta:float):
	pass

func try_to_put_block_stop():
	pass

func _ready() -> void:
	update_chunk_loading()
	initialize_player()

func _process(delta: float) -> void:
	%Camera2D.global_position=%Player.global_position.floor()
	update_chunk_loading()
	update_block_outline(delta)

func _physics_process(_delta: float) -> void:
	var cell_position=get_cell_location(Vector2i(%Player.global_position.floor()))
	%Player.set_position_z(get_altitude_at(cell_position))
