extends "res://scripts/enemy.gd"

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

func _physics_process(delta):
	update_animation()
	decelerate(delta)
	move_and_slide()

func update_animation():
	var hit = check_hit(HITBOX)
	if hit:
		hit_animation()

func hit_animation():
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	ANIMATOR.play("idle")
