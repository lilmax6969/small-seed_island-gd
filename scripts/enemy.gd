class_name Enemy

var DECELERATION: float
var life: int
var knockback: float
var attack_knockback: int

func check_overlaping_area(HITBOX: Area2D) -> Area2D:
	var overlap_areas = HITBOX.get_overlapping_areas()
	
	for area in overlap_areas:
		if area.name != "Sword": 
			continue
		return area
	return null

func apply_knockback(PLAYER: CharacterBody2D, global_position: Vector2,) -> Vector2:
	var look_vector: Vector2 = PLAYER.anim_direction
	var knockback_dir: Vector2 = (global_position - PLAYER.global_position).normalized()
	
	if look_vector.dot(knockback_dir) < 0: 
		return Vector2.ZERO
	
	var new_vel: Vector2 = knockback_dir * knockback
	return new_vel

func check_hit(HITBOX: Area2D, global_position: Vector2) -> Vector2:
	var overlap_area = check_overlaping_area(HITBOX)
	if not overlap_area:
		return Vector2.ZERO
		
	var PLAYER = overlap_area.get_parent()
	var new_vel: Vector2 = apply_knockback(PLAYER, global_position)
	
	if not new_vel or not PLAYER.attack:
		return Vector2.ZERO
	
	return new_vel
