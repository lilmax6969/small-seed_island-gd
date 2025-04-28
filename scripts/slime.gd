extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var idle_cooldown = 2.7

var hit_anim: bool = false
var death_anim: bool = false

func _physics_process(delta):
	path_timer.update_timer(delta)
	knockback_timer.update_timer(delta)
	
	if path_timer.time <= 0:
		ai(PLAYER.global_position)
	
	if life <= 0:
		death_animation()
	else: animate()
	
	update_velocity(delta)
	move_and_slide()

func ai(pos: Vector2):
	var dist = (global_position - pos).length()
	if dist > MAX_DIST:
		randomize()
		var rand_vec = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		var rand_dist = randf_range(10, MAX_DIST)
		var rand_pos = (rand_vec * rand_dist) + global_position
		make_path(rand_pos, idle_cooldown)
	else: make_path(pos)

func animate():
	var hit = check_hit(HITBOX)
	if hit:
		hit_animation()
	
	if hit_anim:
		return
	
	flip()
	if velocity != Vector2.ZERO:
		ANIMATOR.play("walk")
	else: ANIMATOR.play("idle")

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
	
