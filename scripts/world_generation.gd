extends Node

const TREE_LOG_HEIGHT:=3
const TREE_LEAVES_HEIGHT:=1
const TREE_HEIGHT:=TREE_LOG_HEIGHT+TREE_LEAVES_HEIGHT

var height_noise:FastNoiseLite
var ore_presence_noise:FastNoiseLite
var ore_type_noise:FastNoiseLite
var tree_presence_noise:FastNoiseLite

func _ready() -> void:
	height_noise=FastNoiseLite.new()
	height_noise.noise_type=FastNoiseLite.TYPE_PERLIN
	
	ore_presence_noise=FastNoiseLite.new()
	ore_presence_noise.noise_type=FastNoiseLite.TYPE_PERLIN
	
	ore_type_noise=FastNoiseLite.new()
	ore_type_noise.noise_type=FastNoiseLite.TYPE_PERLIN
	
	tree_presence_noise=FastNoiseLite.new()
	tree_presence_noise.noise_type=FastNoiseLite.TYPE_PERLIN

func get_ore_presence_at(x:int,y:int,z:int)->bool:
	const ORE_PRESENCE_SCALING:=16
	return abs(ore_presence_noise.get_noise_3d(
		x*ORE_PRESENCE_SCALING,y*ORE_PRESENCE_SCALING,z*ORE_PRESENCE_SCALING))>=0.2

func get_ore_type_value_at(x:int,y:int,z:int)->float:
	const ORE_TYPE_SCALING:=16
	return ore_type_noise.get_noise_3d(x*ORE_TYPE_SCALING,y*ORE_TYPE_SCALING,z*ORE_TYPE_SCALING)

func get_tree_presence_value_at(x:int,y:int)->float:
	const TREE_PRESENCE_SCALING:=16
	return abs(tree_presence_noise.get_noise_2d(
		x*TREE_PRESENCE_SCALING,y*TREE_PRESENCE_SCALING))

func get_tree_presence_at(x:int,y:int)->bool:
	var value:=get_tree_presence_value_at(x,y)
	for ry in range(-1,1+1):
		for rx in range(-1,1+1):
			if ry!=0 or rx!=0:
				if get_tree_presence_value_at(x+rx,y+ry)>=value:
					return false
	return true

func get_stone_depth_block(x:int,y:int,z:int)->String:
	if not get_ore_presence_at(x,y,z):
		return "stone"
	var type_value=get_ore_type_value_at(x,y,z)
	if type_value<=0:
		return "copper_ore"
	else:
		return "tin_ore"

func get_hard_stone_depth_block(x:int,y:int,z:int)->String:
	if not get_ore_presence_at(x,y,z):
		return "hard_stone"
	return "iron_ore"

func generate_chunk(chunk:Chunk,world_seed:int):
	
	height_noise.seed=world_seed
	ore_presence_noise.seed=world_seed+1
	ore_type_noise.seed=world_seed+2
	tree_presence_noise.seed=world_seed+3
	
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
				elif depth<=8:
					type_name=get_stone_depth_block(world_x,world_y,column.get_height())
				else:
					type_name=get_hard_stone_depth_block(world_x,world_y,column.get_height())
				column.put_block(Block.create(type_name))
			
			if height+TREE_HEIGHT<=BlockColumn.MAX_HEIGHT:
				if get_tree_presence_at(world_x,world_y):
					for i in range(TREE_LOG_HEIGHT):
						column.put_block(Block.create("log"))
					for i in range(TREE_LEAVES_HEIGHT):
						column.put_block(Block.create("leaves"))
