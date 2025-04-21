extends CharacterBody2D

@onready var ANIMATOR = $Animator

@export var ACCELERATION: float = 1250.0
@export var DECELERATION: float = 1500.0
@export var MAX_SPEED: float = 20_00.0

var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	# Direction
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	last_direction = input_direction if input_direction != Vector2.ZERO else last_direction
	
	animate()
	
	update_velocity(delta)
	move_and_slide()

func update_velocity(delta: float) -> void:
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	var maxDelta = MAX_SPEED * delta
	
	# X movement
	if abs(velocity.x) + accDelta > maxDelta:
		velocity.x = maxDelta * input_direction.x
	if input_direction.x != 0:
		velocity.x += input_direction.x * accDelta
	else: 
		velocity.x = move_toward(velocity.x, 0, decDelta)
	
	# Y movement
	if abs(velocity.y) + accDelta > maxDelta:
		velocity.y = maxDelta * input_direction.y
	if input_direction.y != 0:
		velocity.y += input_direction.y * accDelta
	else:
		velocity.y = move_toward(velocity.y, 0, decDelta)

# DANGER: Animations sector 
func animate() -> void:
	flip_logic()
	
	# Idle animation
	if not input_direction:
		idle_animations()
	else:
		walk_animations()

func flip_logic() -> void:
	if last_direction.x < 0 and not last_direction.y:
		ANIMATOR.set_flip_h(true) 
	else: ANIMATOR.set_flip_h(false)

func idle_animations() -> void:
	if last_direction.y > 0:
		ANIMATOR.play("idle_down")
	elif last_direction.y < 0:
		ANIMATOR.play("idle_up")
	else:
		ANIMATOR.play("idle_side")

func walk_animations() -> void:
	if input_direction.y > 0:
		ANIMATOR.play("walk_down")
	elif input_direction.y < 0:
		ANIMATOR.play("walk_up")
	else:
		ANIMATOR.play("walk_side")
