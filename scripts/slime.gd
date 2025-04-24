extends CharacterBody2D


@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var DECELERATION: float = 500.0
@export var life: int = 5
@export var knockback: int = 125
@export var attack_knockback: int = 150

var attacked: bool

func _physics_process(delta):
	attacked = check_hit()
	update_velocity(delta)
	move_and_slide()
	
func update_velocity(delta):
	var decDelta = DECELERATION * delta
	velocity = velocity.move_toward(Vector2.ZERO, decDelta)
	
func check_hit() -> bool:
	var overlapping_areas = HITBOX.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name != "Sword": continue
		var player: CharacterBody2D = area.get_parent()
		
		if not attacked: hitted(player)
		if player.attack: return true
		
	return false

func hitted(player: CharacterBody2D):
	if not player.attack: return
	
	var knockback_dir = (global_position - player.global_position).normalized()
	velocity = knockback * knockback_dir
	
	ANIMATOR.play("hit")
	await ANIMATOR.animation_finished
	ANIMATOR.play("idle")
