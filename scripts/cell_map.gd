extends Node2D

var chunks:={}

func put_chunk(chunk:Chunk):
	var chunk_node_model=preload("res://scenes/cell_map_chunk.tscn")
	if not chunks.has(chunk.location):
		var chunk_node=chunk_node_model.instantiate()
		add_child(chunk_node)
		chunk_node.set_location(chunk.location)
		chunks[chunk.location]=chunk_node

func update_chunk(player_height:int,chunk:Chunk,chunk_up:Chunk,chunk_down:Chunk,chunk_left:Chunk,chunk_right:Chunk):
	assert(chunks.has(chunk.location),
		"Chunk not found in the cell map: "+str(chunk.location.x)+","+str(chunk.location.y))
	chunks[chunk.location].update(player_height,chunk,chunk_up,chunk_down,chunk_left,chunk_right)

func remove_chunk(location:Vector2i):
	if chunks.has(location):
		chunks[location].queue_free()
		chunks.erase(location)
