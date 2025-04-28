extends CharacterBody2D

@onready var ANIMATOR = $Animator
@onready var SWORD = $Sword
@onready var HITBOX = $Hitbox
@onready var COLLISION = $Collision
@onready var CAM = $Camera2D

@export var GROUND: TileMapLayer

@export var ACCELERATION: float = 750.0
@export var DECELERATION: float = 1000.0
@export var MAX_SPEED: float = 75.0
@export var KNOCKBACK_COOLDOWN: float = 0.75
@export var ATTACK_COOLDOWN: float = 0.5

var attack: bool = false
var knockbacked: bool = false
var knockbacked_timer := Global.timer.new(0.0, KNOCKBACK_COOLDOWN)
var attack_timer := Global.timer.new(0.0, ATTACK_COOLDOWN)

var input_direction: Vector2 = Vector2.ZERO
var anim_direction: Vector2 = Vector2.DOWN

var attack_speed_multiplier: float = 1.3
var flipped: int = 1

var default_sword_pos: Vector2

func _ready():
	default_sword_pos = SWORD.position

func _physics_process(delta: float) -> void:
	# Update timer
	knockbacked_timer.update_timer(delta)
	attack_timer.update_timer(delta)
	
	# Direction
	input()
	
	if not attack:
		anim_direction = input_direction if input_direction != Vector2.ZERO else anim_direction
		animate()
	
	# Check for a hit
	check_hit()
	
	# Update position
	update_velocity(delta)
	move_and_slide()

func input():
	input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	if (
		Input.is_action_just_pressed("attack") and 
		not attack and attack_timer.time <= 0 and
		not knockbacked
	): 
		attack = true
		attack_timer.reset()
		attack_animations()

func update_velocity(delta: float) -> void:
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	
	if (
		input_direction != Vector2.ZERO and 
		not attack and
		not knockbacked
	):
		velocity += input_direction * accDelta
		if velocity.length() > MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, decDelta)
	
	if knockbacked and velocity == Vector2.ZERO: 
		knockbacked = false 

func update_timer(timer: float, delta: float) -> float:
	if timer <= 0:
		return 0.0
	return timer - delta

# DANGER: Animations sector 
func animate() -> void:
	flip_logic()
	
	if attack or knockbacked: 
		return
	
	# Idle & walking animations
	ANIMATOR.speed_scale = 1
	if not input_direction:
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

func attack_animations() -> void:
	if anim_direction.y > 0:
		SWORD.position.y = ANIMATOR.position.y + 14
		
		ANIMATOR.play("attack_down")
		ANIMATOR.offset.y = 7
	elif anim_direction.y < 0:
		SWORD.position.y = ANIMATOR.position.y - 2
		
		ANIMATOR.play("attack_up")
		ANIMATOR.offset.y = -9.5
	else:
		SWORD.rotation = PI/2 * flipped
		SWORD.position = ANIMATOR.position + Vector2(3 * flipped, -1)
		
		ANIMATOR.play("attack_side")
		ANIMATOR.offset.x = 8 * flipped
	
	ANIMATOR.speed_scale = attack_speed_multiplier
	await ANIMATOR.animation_finished
	stop_attack()

func stop_attack() -> void:
	# Cancel the attack
	attack = false
	
	# Reset the animator
	ANIMATOR.speed_scale = 1
	ANIMATOR.offset = Vector2.ZERO
	
	# Reset the Sword
	SWORD.rotation = 0
	SWORD.position = default_sword_pos
	
	# Force a visual update
	animate()

func hit_animations() -> void:
	ANIMATOR.speed_scale = 2
	
	if anim_direction.y > 0:
		ANIMATOR.play("hit_down")
	elif anim_direction.y < 0:
		ANIMATOR.play("hit_up")
	else: ANIMATOR.play("hit_side")
	
	await ANIMATOR.animation_finished
	ANIMATOR.speed_scale = 1

# ALERT: Ultra DANGER zone (knockback)
func check_hit():
	var area = Global.check_overlap(HITBOX, "Damage")
	if not area: return
	if knockbacked_timer.time > 0: return
	
	var enemy = area.get_parent()
	var att_direction: Vector2 = (global_position - enemy.global_position).normalized()
	
	velocity = att_direction * enemy.attack_knockback
	
	knockbacked = true
	knockbacked_timer.reset()
	
	# Cancel the attack
	if attack:
		attack = false
		ANIMATOR.stop()
		stop_attack()
	
	hit_animations()
	animate()
