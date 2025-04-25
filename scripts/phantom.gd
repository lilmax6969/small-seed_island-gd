extends CharacterBody2D

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

var enemy = Enemy.new()

func _ready():
	enemy.DECELERATION = 500.0
	enemy.life = 5
	enemy.knockback = 100
	enemy.attack_knockback = 150

func _physics_process(delta):
	update_life()
	update_velocity(delta)
	move_and_slide()

func update_velocity(delta):
	var decDelta = enemy.DECELERATION * delta
	velocity = velocity.move_toward(Vector2.ZERO, decDelta)

func update_life():
	var new_vel: Vector2 = enemy.check_hit(HITBOX, global_position)
	if not new_vel:
		return
	
	velocity = new_vel
	hit_animation()

func hit_animation():
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	ANIMATOR.play("idle")	
