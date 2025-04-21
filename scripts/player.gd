extends CharacterBody2D

const SIZE:=24
const SPEED:=5

var position_z:int=0

func _init() -> void:
	set_position_z(Chunk.MAX_HEIGHT)

func set_position_z(z:int):
	position_z=z
	if z>=0 and z<32:
		collision_layer=(1<<z)
		collision_mask=(1<<z)
	else:
		collision_layer=0
		collision_mask=0

func _physics_process(_delta: float) -> void:
	var movement:=Vector2(0,0)
	movement.x=Input.get_axis("move_left","move_right")
	movement.y=Input.get_axis("move_up","move_down")
	if movement.length()>1:
		movement=movement.normalized()
	if movement.length()>0:
		%Sprite2D.rotation=movement.angle()+PI/2
	movement*=SPEED*Cell.SIZE
	
	velocity=movement
	move_and_slide()
