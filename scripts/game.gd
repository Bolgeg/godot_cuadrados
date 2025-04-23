extends Node2D

const CAMERA_RECT_MAX_OFFSET_OUTSIDE:=50

const BLOCK_OUTLINE_MAX_DISTANCE:=5.0

const TIME_TO_PUT_BLOCK:=1

var world_seed:=0
var chunks:={}
var inventory:Inventory=Inventory.new()

var inventory_mouse_item:=Item.create_empty()

var block_outline_active:=false
var block_outline_location:=Vector2i(0,0)

var breaking_block_time:=0.0
var breaking_block_position:=Vector2i(0,0)

var putting_block_time:=0.0
var putting_block_position:=Vector2i(0,0)

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

func get_block_column_at(cell_location:Vector2i)->BlockColumn:
	var chunk_location:=get_chunk_location(cell_location)
	if chunks.has(chunk_location):
		var chunk:Chunk=chunks[chunk_location]
		var cell_location_in_chunk=cell_location-chunk_location*Chunk.SIZE
		return chunk.column_at(cell_location_in_chunk.x,cell_location_in_chunk.y)
	return null

func get_altitude_at(cell_location:Vector2i)->int:
	var column:=get_block_column_at(cell_location)
	if column!=null:
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
	
	if %InventoryContainer.visible:
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
	else:
		try_to_break_block_stop()
		try_to_put_block_stop()

func update_breaking_block_overlay():
	if breaking_block_time==0:
		%BreakingBlockOverlay.visible=false
	else:
		%BreakingBlockOverlay.visible=true
		%BreakingBlockOverlay.global_position=breaking_block_position*Cell.SIZE
		var breaking_block_progress:=0.0
		var time_to_break_block=get_time_to_break_block(breaking_block_position)
		if time_to_break_block!=0:
			breaking_block_progress=breaking_block_time/time_to_break_block
		%BreakingBlockOverlay.update_state(breaking_block_progress)

func try_to_break_block_progress(cell_location:Vector2i,delta:float):
	if breaking_block_time==0:
		if is_cell_block_breakable(cell_location):
			breaking_block_position=cell_location
			breaking_block_time+=delta
	else:
		if cell_location!=breaking_block_position:
			breaking_block_time=0
			breaking_block_position=cell_location
		else:
			breaking_block_time+=delta
			var time_to_break=get_time_to_break_block(breaking_block_position)
			if breaking_block_time>=time_to_break:
				break_block(breaking_block_position)
				breaking_block_time=0

func try_to_break_block_stop():
	breaking_block_time=0

func try_to_put_block_progress(cell_location:Vector2i,delta:float):
	if putting_block_time==0:
		if is_cell_block_puttable(cell_location):
			putting_block_position=cell_location
			putting_block_time=delta
			put_block(putting_block_position)
	else:
		if cell_location!=putting_block_position:
			putting_block_position=cell_location
			putting_block_time=delta
			if is_cell_block_puttable(putting_block_position):
				put_block(putting_block_position)
		else:
			putting_block_time+=delta
			var time_to_put=TIME_TO_PUT_BLOCK
			if putting_block_time>=time_to_put:
				if is_cell_block_puttable(putting_block_position):
					put_block(putting_block_position)
				putting_block_time=0

func try_to_put_block_stop():
	putting_block_time=0

func is_cell_block_breakable(cell_location:Vector2i)->bool:
	var column:=get_block_column_at(cell_location)
	if column==null:
		return false
	else:
		return column.get_height()>1

func get_time_to_break_block(cell_location:Vector2i)->float:
	var time:=1.0
	var column:=get_block_column_at(cell_location)
	if column!=null:
		time=column.get_top_block().get_time_to_break()
	var speed:=get_current_tool_speed()
	assert(speed!=0,"Current tool speed is zero")
	return time/speed

func break_block(cell_location:Vector2i):
	var column:=get_block_column_at(cell_location)
	if column==null:
		return
	var block:=column.get_top_block()
	column.remove_block()
	player_get_block(block)

func is_cell_block_puttable(cell_location:Vector2i)->bool:
	var column:=get_block_column_at(cell_location)
	if column==null:
		return false
	else:
		return column.get_height()<Chunk.MAX_HEIGHT

func put_block(cell_location:Vector2i):
	var column:=get_block_column_at(cell_location)
	if column==null:
		return
	if player_can_put_block():
		column.put_block(player_put_block())

func player_get_block(block:Block):
	inventory.add_item(block.get_item())

func player_can_put_block()->bool:
	return inventory.item_is_block(%Toolbar.selected_item_index)

func player_put_block()->Block:
	return inventory.remove_item(%Toolbar.selected_item_index).get_block()

func get_current_tool_speed()->float:
	return inventory.get_item_tool_speed(%Toolbar.selected_item_index)

func _ready() -> void:
	update_chunk_loading()
	initialize_player()

func _process(delta: float) -> void:
	%Camera2D.global_position=%Player.global_position.floor()
	update_chunk_loading()
	update_block_outline(delta)
	update_breaking_block_overlay()
	%InventoryContainer.update_items(inventory)
	%InventoryContainer.update_mouse_item(inventory_mouse_item)
	%Toolbar.update_items(inventory)

func _physics_process(_delta: float) -> void:
	var cell_position=get_cell_location(Vector2i(%Player.global_position.floor()))
	%Player.set_position_z(get_altitude_at(cell_position))
	%Player.movable=not %InventoryContainer.visible


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		if %InventoryContainer.visible:
			if not inventory_mouse_item.is_empty():
				inventory.add_item(inventory_mouse_item)
				inventory_mouse_item=Item.create_empty()
			%InventoryContainer.close()
		else:
			%InventoryContainer.open()

func _on_inventory_container_mouse_clicked_to_move_item(item_index: int) -> void:
	var item:Item=inventory.items[item_index]
	item.swap(inventory_mouse_item)
