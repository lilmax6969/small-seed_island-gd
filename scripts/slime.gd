extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var idle_cooldown: float = 0.75
@export var wandering_cooldown: float = 2.3

var starting_pos: Vector2
var actual_idle_cooldown: float

var target_pos: Vector2 = Global.impossible_target

var hit_anim: bool = false
var death_anim: bool = false
var move_anim: bool = false

var idle_timer = Global.timer.new(0.0, idle_cooldown) 

func _ready():
	starting_pos = global_position
	actual_idle_cooldown = idle_cooldown

func _physics_process(delta):
	path_timer.update_timer(delta)
	knockback_timer.update_timer(delta)
	idle_timer.update_timer(delta)
	
	if life <= 0:
		velocity = Vector2.ZERO
		death_animation()
	else: 
		if path_timer.time <= 0:
			ai(PLAYER.global_position)
		animate()
		if idle_timer.time <= 0:
			update_velocity(delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, delta * DECELERATION)
	
		move_and_slide()

func ai(pos: Vector2) -> void:
	var dist: float = (global_position - pos).length()
	if dist > MAX_DIST:
		if target_pos == Global.impossible_target:
			randomize()
			var rand_dist = randf_range(10, MAX_DIST)
			var random_vec = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * rand_dist
			target_pos = starting_pos + random_vec
			actual_idle_cooldown = idle_cooldown
			make_path(target_pos, wandering_cooldown)
		
		elif (global_position - target_pos).length() <= 10:
			target_pos = Global.impossible_target
		
		else:
			make_path(target_pos, wandering_cooldown)
	else: 
		actual_idle_cooldown = idle_cooldown / 1.5
		target_pos = Global.impossible_target
		make_path(pos)

func animate():
	var hit = check_hit(HITBOX)
	if hit:
		hit_animation()
	
	if hit_anim:
		return
	
	flip()
	if idle_timer.time <= 0:
		move_animation()
	else: 
		ANIMATOR.play("idle")

func flip():
	if velocity.x > 0:
		ANIMATOR.set_flip_h(false)
	elif velocity.x < 0:
		ANIMATOR.set_flip_h(true)

func hit_animation():
	hit_anim = true
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	ANIMATOR.play("idle")
	hit_anim = false

func death_animation():
	death_anim = true
	ANIMATOR.play("death")
	await ANIMATOR.animation_finished
	queue_free()
	
func move_animation():
	ANIMATOR.play("walk")
	await ANIMATOR.animation_finished
	idle_timer.reset(actual_idle_cooldown)
	animate()
