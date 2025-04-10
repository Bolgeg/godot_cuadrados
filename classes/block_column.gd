class_name BlockColumn
extends RefCounted

const MAX_HEIGHT:=Chunk.MAX_HEIGHT

var blocks:=[]

func _init() -> void:
	blocks.append(Block.create(Globals.get_base_block_type_name()))

func get_height()->int:
	return blocks.size()

func get_top_block()->Block:
	return blocks.back()

func put_block(block:Block):
	if blocks.size()<MAX_HEIGHT:
		blocks.append(block)

func remove_block():
	if blocks.size()>1:
		blocks.pop_back()
