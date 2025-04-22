extends CharacterBody2D

@onready var ANIMATOR = $Animator

@export var ACCELERATION: float = 750.0
@export var DECELERATION: float = 1000.0
@export var MAX_SPEED: float = 75.0

var input_direction: Vector2 = Vector2.ZERO
var anim_direction: Vector2 = Vector2.DOWN

var attack: bool = false
var attack_speed_multiplier: float = 1
var flipped: int = 1

func input():
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	if Input.is_action_just_pressed("attack") and not attack: 
		attack = true
		attack_animations()

func _physics_process(delta: float) -> void:
	# Direction
	if not attack:
		input()
		anim_direction = input_direction if input_direction != Vector2.ZERO else anim_direction
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
	
	if attack: return
	
	# Idle & walking animations
	elif not input_direction:
		idle_animations()
	else:
		walk_animations()

func flip_logic() -> void:
	if anim_direction.x < 0 and not anim_direction.y:
		ANIMATOR.set_flip_h(true) 
		flipped = -1
	else: 
		ANIMATOR.set_flip_h(false)
		flipped = 1

func idle_animations() -> void:
	if anim_direction.y > 0:
		ANIMATOR.play("idle_down")
	elif anim_direction.y < 0:
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

func offset_logic() -> void:
	if not attack: 
		ANIMATOR.offset = Vector2.ZERO
	
	else:
		if anim_direction.y > 0:
			ANIMATOR.offset.y = 7
		elif anim_direction.y < 0:
			ANIMATOR.offset.y = -9.5
		else:
			ANIMATOR.offset.x = 8 * flipped

func attack_animations() -> void:
	offset_logic()
	
	ANIMATOR.speed_scale = attack_speed_multiplier
	
	if anim_direction.y > 0:
		ANIMATOR.play("attack_down")
	elif anim_direction.y < 0:
		ANIMATOR.play("attack_up")
	else:
		ANIMATOR.play("attack_side")
	
	await ANIMATOR.animation_finished
	
	# Cancel the attack
	attack = false
	
	# Reset the offset and speed
	ANIMATOR.speed_scale = 1
	offset_logic()
	
	# Force a visual update
	animate()
