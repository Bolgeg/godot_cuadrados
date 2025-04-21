class_name Chunk
extends RefCounted

const SIZE:=4
const MAX_HEIGHT:=32

var location:=Vector2i(0,0)
var block_columns:=[]

func _init(location_to_set:Vector2i) -> void:
	location=location_to_set
	for i in range(SIZE*SIZE):
		block_columns.append(BlockColumn.new())

func column_at(x:int,y:int)->BlockColumn:
	if x<0:
		x+=SIZE
	if x>=SIZE:
		x-=SIZE
	if y<0:
		y+=SIZE
	if y>=SIZE:
		y-=SIZE
	return block_columns[y*SIZE+x]
