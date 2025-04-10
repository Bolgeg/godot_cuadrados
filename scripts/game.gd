extends Node2D

var world_seed:=0
var chunks:={}

func load_chunk(location:Vector2i):
	if not chunks.has(location):
		chunks[location]=Chunk.new(location)
		WorldGeneration.generate_chunk(chunks[location],world_seed)

func unload_chunk(location:Vector2i):
	if chunks.has(location):
		chunks.erase(location)

func _ready() -> void:
	
	#----test----
	load_chunk(Vector2i(0,0))
	%CellMap.put_chunk(chunks[Vector2i(0,0)])
	%CellMap.update_chunk(32,chunks[Vector2i(0,0)],null,null,null,null)
	#----test----
