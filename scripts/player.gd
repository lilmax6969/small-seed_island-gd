extends CharacterBody2D

@export var ACCELERATION: float = 1750.0
@export var DECELERATION: float = 2000.0
@export var MAX_SPEED: float = 15_000.0

var input_direction: Vector2

func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down").normalized()

func update_velocity(delta: float) -> void:
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	var maxDelta = MAX_SPEED * delta
	
	# X movement
	if input_direction.x != 0:
		velocity.x += input_direction.x * accDelta
	else: 
		velocity.x = move_toward(velocity.x, 0, decDelta)
	
	# Y movement
	if input_direction.y != 0:
		velocity.y += input_direction.y * accDelta	
	else:
		velocity.y = move_toward(velocity.y, 0, decDelta)
	
	# Max speed
	velocity.x = maxDelta * input_direction.x if abs(velocity.x) > maxDelta else velocity.x
	velocity.y = maxDelta * input_direction.y if abs(velocity.y) > maxDelta else velocity.y  

func _physics_process(delta: float) -> void:
	input_direction = get_input_direction()
	update_velocity(delta)
	move_and_slide()
