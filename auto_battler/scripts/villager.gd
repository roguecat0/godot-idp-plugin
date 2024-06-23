extends CharacterBody2D


# fodot inputs
const MAX_HP = 10.0
const MAX_AGE = 30
var health = MAX_HP
var color: String
var age: int = 0

# fodot state output
var curr_state = "fight"

# state managment
var in_area: bool = false
var target_pos: Vector2 = Vector2(0,0)
var moving: bool = true

# identification
var player_char = true
var id
static var next_id = 0


# attributes
const regen_rate = [1.5,1.5,1.5]
const farm_rate = [1.5,1,1]
const attack_rate = [1,1.5,0.5]
const speed = [80.0,60.0,40.0]

@onready var nav: NavigationAgent2D = $NavigationAgent2D

var player_animations = {
	"Farm": "farm_right",
	"Fight": "fight_right",
	"Rest": "idle"
}
var enemy_animations = {
	"Farm": "farm_left",
	"Fight": "fight_left",
	"Rest": "idle"
}

signal died(id)

func _ready() -> void:
	id = get_next_id()
	
func setup(color_, state_, player_) -> void:
	player_char = player_
	curr_state = state_
	color = color_
	match color:
		"Red": set_color(Color("ff3947"))
		"Green": set_color(Color("00a614"))
		"Blue": set_color(Color("5f8af7"))
		_: assert(false, color + ", not in possible colors")
		
func age_bracket():
	return age/10
		
func age_up():
	age += 1
	if age >= MAX_AGE:
		die()
	
func regenerate(delta: float):
	health = max(MAX_HP, health + delta*regen_rate[age_bracket()])
	
func farm(delta: float):
	return farm_rate[age_bracket()] * delta
	
func attack(delta: float):
	return attack_rate[age_bracket()] * delta
	
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()
		

static func get_next_id():
	next_id += 1
	return next_id
	
func set_color(color: Color):
	$Anim.modulate = color

func _physics_process(delta: float) -> void:
	nav.target_position = target_pos
	var direction = nav.get_next_path_position() - global_position
	#print(direction.length())
	moving = true
	if direction.length() <= 1.0:
		moving = false
	else:
		direction = direction.normalized()
		velocity = direction * speed[age_bracket()]
		move_and_slide()
	animation_handler(direction)
	
	

func set_map(rid):
	nav.set_navigation_map(rid)

func state_handler(delta: float):
	pass
	
func animation_handler(direction: Vector2):
	var angle = direction.angle()
	if not moving:
		play_state_animation()
	elif abs(angle) < PI/4:
		$Anim.play("run_right")
	elif abs(angle) > PI*3/4:
		$Anim.play("run_left")
	elif angle > 0:
		$Anim.play("run_down")
	else:
		$Anim.play("run_up")
	
func die():
	#print("DIED!")
	died.emit(id)
	queue_free()
		
func play_hurt():
	$Greeny.play("hurt")
	await $Greeny.animation_looped
	$Greeny.play("run")
	
func get_animations():
	return player_animations if player_char else enemy_animations
	
func play_state_animation():
	$Anim.play(get_animations()[curr_state])
	
func _to_string() -> String:
	return "villager%d (health: %f, color: %s, age: %d)" % [id, health, color, age]
	
