extends CharacterBody2D

@onready var ANIMATOR = $Animator

@export var ACCELERATION: float = 750.0
@export var DECELERATION: float = 1000.0
@export var MAX_SPEED: float = 75.0

var input_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var attack: bool = false

func input():
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	if Input.is_action_just_pressed("attack"): attack = true
	else: attack = false

func _physics_process(delta: float) -> void:
	# Direction
	input()
	last_direction = input_direction if input_direction != Vector2.ZERO else last_direction
	
	animate()
	
	update_velocity(delta)
	move_and_slide()

func update_velocity(delta: float) -> void:
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	
	if input_direction != Vector2.ZERO:
		velocity += input_direction * accDelta
		if velocity.length() > MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decDelta)

# DANGER: Animations sector 
func animate() -> void:
	flip_logic()
	
	# Idle animation
	if not input_direction:
		idle_animations()
	elif attack == true:
		attack_animation()
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

func attack_animation() -> void:
	if input_direction.y > 0:
		ANIMATOR.play("attack_down")
	elif input_direction.y < 0:
		ANIMATOR.play("attack_up")
	else:
		ANIMATOR.play("attack_right")
