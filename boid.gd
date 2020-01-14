extends KinematicBody2D

onready var sprite = $Sprite
onready var col = $CollisionShape2D
onready var steering = get_node("../../") #Flocking Node
var pos = get_global_position()
var vel
var flocking = false
var force = Vector2.ZERO

func _ready():
	
	#velocity in random direction for testing purposes
	#vel = Vector2(randf()-0.5, randf()-0.5).normalized()
	vel = Vector2.ZERO
	pass

func _physics_process(delta):
	#this vel-variable gets updated constantly by the main-scene.
	move_and_slide(vel * steering.max_speed)
	pos = get_global_position()
	check_boundaries()
	blush()

#if this boid is affected by group-steering forces, it will change color
func blush():
	if flocking:
		sprite.modulate = Color(1,0.7,0.7,1)
	else:
		sprite.modulate = Color.white

#setters and getters for boid's individual velocity
func get_vel():
	return vel

func set_vel(v):
	vel = v

#wrap around screen
func check_boundaries():
	
	if pos.x > OS.get_window_size().x:
		set_global_position(Vector2(0, pos.y))
	elif pos.x < 0:
		set_global_position(Vector2(OS.get_window_size().x, pos.y))

	if pos.y > OS.get_window_size().y:
		set_global_position(Vector2(pos.x, 0))
	elif pos.y < 0:
		set_global_position(Vector2(pos.x, OS.get_window_size().y))
	

