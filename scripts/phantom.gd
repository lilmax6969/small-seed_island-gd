extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var idle_cooldown: float = 2

var hitted: bool = false

func _physics_process(delta):
	knockback_timer.update_timer(delta)
	path_timer.update_timer(delta)
	
	if path_timer.time <= 0:
		ai(PLAYER.global_position)
	
	animate()
	
	update_velocity(delta)
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
	if velocity.x > 0:
		ANIMATOR.set_flip_h(false)
	elif velocity.x < 0:
		ANIMATOR.set_flip_h(true)

func ai(pos: Vector2) -> void:
	var dist: float = (global_position - pos).length()
	print(dist, ' ', path_timer.time)
	if dist > MAX_DIST:
		randomize()
		var rand_dist = randf_range(5, MAX_DIST)
		var random_vec = Vector2(randf_range(1, -1), randf_range(1, -1)) * rand_dist
		var rand_pos = global_position + random_vec
		make_path(rand_pos, 2)
	else: 
		make_path(pos)
