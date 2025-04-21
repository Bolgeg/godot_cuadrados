extends Node

var height_noise:FastNoiseLite

func _ready() -> void:
	height_noise=FastNoiseLite.new()
	height_noise.noise_type=FastNoiseLite.TYPE_PERLIN

func generate_chunk(chunk:Chunk,world_seed:int):
	height_noise.seed=world_seed
	for y in range(Chunk.SIZE):
		for x in range(Chunk.SIZE):
			var column:=chunk.column_at(x,y)
			var world_x:int=chunk.location.x*Chunk.SIZE+x
			var world_y:int=chunk.location.y*Chunk.SIZE+y
			var height:int=16+int(round(16*height_noise.get_noise_2d(world_x*4,world_y*4)))
			if height<1:
				height=1
			elif height>BlockColumn.MAX_HEIGHT:
				height=BlockColumn.MAX_HEIGHT
			
			while column.get_height()<height:
				var type_name:="stone"
				var depth:int=height-column.get_height()
				if depth<=1:
					type_name="grass"
				elif depth<=4:
					type_name="dirt"
				column.put_block(Block.create(type_name))
			
