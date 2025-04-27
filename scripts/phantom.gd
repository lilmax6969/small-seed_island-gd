extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

func _physics_process(delta):
	knockback_timer = update_timer(knockback_timer, delta)
	path_timer = update_timer(path_timer, delta)
	
	if path_timer <= 0:
		make_path(PLAYER.global_position)
	
	animate()
	update_velocity(delta)
	move_and_slide()

func hit_animation():
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	ANIMATOR.play("idle")

func animate():
	var hit = check_hit(HITBOX)
	if hit:
		hit_animation()
	
	if knockback_timer <= 0:
		flip_logic()
	
	if velocity.length() != 0:
		ANIMATOR.play("walk")
	else: ANIMATOR.play("idle")

func flip_logic():
	if velocity.x > 0:
		ANIMATOR.set_flip_h(false)
	elif velocity.x < 0:
		ANIMATOR.set_flip_h(true)
