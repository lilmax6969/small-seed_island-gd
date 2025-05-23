extends CharacterBody2D

@onready var PATH = $Pathfinding
@export var PLAYER: CharacterBody2D

@export var DECELERATION: float = 500.0
@export var ACCELERATION: float = 500.0
@export var MAX_SPEED: float = 30.0
@export var MAX_DIST: float = 95.0

@export var life: int = 5
@export var knockback_force: float = 150.0
@export var attack_knockback: int = 200.0

@export var path_cooldown: float = 0.75
@export var knockback_cooldown: float = 0.5

var path_timer = Global.timer.new(0.0, path_cooldown)
var knockback_timer = Global.timer.new(0.0, knockback_cooldown)

func make_path(pos: Vector2, cooldown = null):
	PATH.target_position = pos
	path_timer.reset(cooldown)

func update_velocity(delta):
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	
	var next_pos = PATH.get_next_path_position()
	var direction = (next_pos - global_position)
	if direction.length() > 1:
		direction = direction.normalized()
	else:
		direction = Vector2.ZERO
	
	if knockback_timer.time <= 0:
		velocity += accDelta * direction
		if velocity.length() >= MAX_SPEED:
			velocity = MAX_SPEED * velocity.normalized() 
	else: velocity = velocity.move_toward(Vector2.ZERO, decDelta)

func apply_knockback(PLAYER: CharacterBody2D) -> bool:
	var look_vector: Vector2 = PLAYER.anim_direction
	var knockback_dir: Vector2 = (global_position - PLAYER.global_position).normalized()
	
	if look_vector.dot(knockback_dir) < 0: 
		return false
	
	velocity = knockback_dir * knockback_force
	knockback_timer.reset()
	return true

func check_hit(HITBOX: Area2D) -> bool:
	var overlap_area = Global.check_overlap(HITBOX, "Sword")
	if not overlap_area:
		return false
	
	var player = overlap_area.get_parent()
	if not player.attack or knockback_timer.time > 0:
		return false
	
	var hit = apply_knockback(PLAYER)
	life -= 1 if hit else 0
	
	if life <= 0:
		return false
	
	return hit

func update_timer(timer: float, delta: float) -> float:
	return timer - delta if timer - delta > 0 else 0.0
