extends CharacterBody2D

@onready var ANIMATOR = $Animator
@onready var HITBOX = $Damage

@export var DECELERATION: float = 750.0
@export var life: int = 5
@export var knockback: int = 150
@export var attack_knockback: int = 250

var attacked: bool

func _physics_process(delta):
	#print(life)
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
	velocity += knockback * player.anim_direction
