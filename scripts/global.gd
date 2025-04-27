extends Node

class timer:
	var time: float
	var cooldown: float
	
	func _init(start: float, _cooldown: float):
		self.time = start
		self.cooldown = _cooldown
	
	func update_timer(delta):
		self.time = self.time - delta if self.time > 0.0 else 0.0
	
	func reset(custom_cooldown = null) -> void:
		self.time = custom_cooldown if custom_cooldown != null else self.cooldown

func check_overlap(AREA: Area2D, area_name: String) -> Area2D:
	var overlap = AREA.get_overlapping_areas()
	
	for area in overlap:
		if area.name != area_name:
			continue
		return area
	return null
