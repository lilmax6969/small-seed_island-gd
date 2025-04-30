extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var wandering_cooldown: int = 2

var starting_pos: Vector2

var target: Vector2 = Global.impossible_target
var idle: bool = false

var hitted: bool = false
var death_anim: bool = false

func _ready():
	starting_pos = global_position

func _physics_process(delta):
	knockback_timer.update_timer(delta)
	path_timer.update_timer(delta)
	
	if path_timer.time <= 0:
		idle = false
		ai(PLAYER.global_position)
	
	if life <= 0:
		velocity = Vector2.ZERO
		death_animation()
	else: 
		if not idle:
			update_velocity(delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
			
		animate()
		move_and_slide()

func hit_animation():
	hitted = true
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	hitted = false
	ANIMATOR.play("idle")

func animate():
	var hit = check_hit(HITBOX)
	if hit:
		hit_animation()
	
	if hitted:
		return
	
	if knockback_timer.time <= 0:
		flip_logic()
	
	if velocity.length() != 0:
		ANIMATOR.play("walk")
	else: ANIMATOR.play("idle")

func flip_logic():
	if abs(velocity.x) < 1.0:
		return
	if velocity.x > 0:
		ANIMATOR.set_flip_h(false)
	elif velocity.x < 0:
		ANIMATOR.set_flip_h(true)

func ai(pos: Vector2) -> void:
	var dist: float = (global_position - pos).length()
	if dist > MAX_DIST:
		if target == Global.impossible_target:
			randomize()
			var rand_dist = randf_range(10, MAX_DIST)
			var random_vec = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * rand_dist
			var rand_pos = starting_pos + random_vec
			target = rand_pos
			make_path(target)
			
		elif (global_position - target).length() <= 10:
			target = Global.impossible_target
			path_timer.reset(wandering_cooldown)
			idle = true
			
		else:
			make_path(target)
	else: 
		make_path(pos)

func death_animation():
	death_anim = true
	ANIMATOR.play("death")
	await ANIMATOR.animation_finished
	queue_free()
