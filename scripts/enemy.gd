extends CharacterBody2D

@export var DECELERATION: float = 500.0
@export var life: int = 5
@export var knockback_force: float = 150.0
@export var attack_knockback: int = 100.0

func decelerate(delta: float):
	var decDelta = DECELERATION * delta
	velocity = velocity.move_toward(Vector2.ZERO, decDelta)

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

func check_hit(HITBOX: Area2D) -> bool:
	var overlap_area = check_overlaping_area(HITBOX)
	if not overlap_area:
		return false
	
	var PLAYER = overlap_area.get_parent()
	if not PLAYER.attack:
		return false
	
	apply_knockback(PLAYER)
	return true
