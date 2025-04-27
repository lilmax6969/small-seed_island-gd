extends CharacterBody2D

@onready var PATH = $Pathfinding
@export var PLAYER: CharacterBody2D

@export var DECELERATION: float = 500.0
@export var ACCELERATION: float = 500.0
@export var MAX_SPEED: float = 30.0

@export var life: int = 5
@export var knockback_force: float = 150.0
@export var attack_knockback: int = 200.0

@export var path_cooldown: float = 0.75
@export var knockback_cooldown: float = 0.5

var path_timer: float = 0.0
var knockback_timer: float = 0.0

func make_path(pos: Vector2):
	PATH.target_position = pos
	path_timer = path_cooldown

func update_velocity(delta):
	var accDelta = ACCELERATION * delta
	var decDelta = DECELERATION * delta
	var direction = to_local(PATH.get_next_path_position()).normalized() 
	
	if knockback_timer <= 0:
		velocity += accDelta * direction
		if velocity.length() >= MAX_SPEED:
			velocity = MAX_SPEED * velocity.normalized() 
	else: velocity = velocity.move_toward(Vector2.ZERO, decDelta)

func check_overlaping_area(HITBOX: Area2D) -> Area2D:
	var overlap_areas = HITBOX.get_overlapping_areas()
	
	for area in overlap_areas:
		if area.name != "Sword": 
			continue
		return area
	return null

func apply_knockback(PLAYER: CharacterBody2D):
	var look_vector: Vector2 = PLAYER.anim_direction
	var knockback_dir: Vector2 = (global_position - PLAYER.global_position).normalized()
	
	if look_vector.dot(knockback_dir) < 0: 
		return
	
	velocity = knockback_dir * knockback_force
	knockback_timer = knockback_cooldown

func check_hit(HITBOX: Area2D) -> bool:
	var overlap_area = check_overlaping_area(HITBOX)
	if not overlap_area:
		return false
	
	var player = overlap_area.get_parent()
	if not player.attack or knockback_timer > 0:
		return false
	
	apply_knockback(PLAYER)
	return true

func update_timer(timer: float, delta: float) -> float:
	return timer - delta if timer - delta > 0 else 0.0
