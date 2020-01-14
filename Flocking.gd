extends Node2D

### AUTONOMOUS AGENT FLOCKING DEMO
# by meloonics
# based on Craig Reynolds' boids
# https://www.red3d.com/cwr/boids/
# and 'The Nature of Code' by Daniel Shiffman
# https://natureofcode.com/


export(float, 1, 100) var max_speed = 25 #max velocity of a boid
export(float, 1, 100) var max_force = 1 #max force acted upon a boid per frame
export(int, 1, 100) var population = 20 #Decrease this if you experience LAG
export(float, 1, 200) var comfort_zone = 64 #maximum radius in which boid will respond to local flockmates. This should at least be bigger than the boid's collisionshape
export(float, -1.0, 1.0) var field_of_view = 0 #view angle [-1 = 360°, 0 = 180°, 1 = 0°] so at 1 the boids will practically be blind
export(int, 0, 400) var target_radius = 200 #radius in which seek-force takes effect.
export(int, 0, 200) var brake_radius = 100 #radius around target. boids in this radius will slow down. Set to 0 to disable
export(bool) var disable_collision = false #Check this if you experience even more LAG
export(float, 1, 10) var mass = 1 #boid mass, important for wind/gravity

#These variables determine how forces are weighted against each other. 0 turns a force off
export(float, 0, 1) var master_factor = 1 #handles intensity of all forces except friction
export(float, -1, 1) var seek_factor = 0 #desire to seek the target
export(float, 0, 1) var separation_factor = 0.5 #desire to gain distance to other boids
export(float, 0, 1) var alignment_factor = 0.5 #desire to align movement with other boids
export(float, 0, 1) var cohesion_factor = 0.5 #desire to find average position of other boids
export(float, 0, 1) var random_factor = 0 #desire to fuck around
export(float, -1, 1) var gravity_factor = 0 #desire to go down/up, multiplied by mass
export(float, -1, 1) var wind_factor = 0 #desire to go left/right, divided by mass
export(float, 0, 1) var friction_factor = 0.01 #percentage of velocity loss per frame

#Bools to turn drawing on and off
export(bool) var draw_velocity = false
export(bool) var draw_force = false
export(bool) var draw_fov = false

export(OpenSimplexNoise) var pnoise # Perlin-Noise for random movement

#### Variables for V E C T O R C A L X ####

#if boids are in range of this value, they will stop immediately
const PIXEL_RADIUS = 3 

var current_boid

#Velocity - the actual movement
var vel

#Acceleration/Desire - movement's target
var acc
# the acceleration-vector will be processed by the various steering functions
# it describes the desired target of a boid

var steer 
#Steering = (acc - vel) ; movement's change over time
#this bad boy will be added to the current velocity in the end when all the math is done

var pos  #Position - Shortcut for boid.get_global_position()
var dir  #Direction - Shortcut for vel.angle()
var target  #Target the boids will be seeking (in this case mouse-cursor, but it can be any Vector2-Posiion you want.)
onready var targetsprite = $target

# Stuff for spawning boids
var boidscene = preload("res://boid.tscn")
var boid_array = [] #Array of all boids in the scene. important for group steering
var screen_dimension #window size
var flockmates = [] #Array of all local flockmates of the current boid
onready var nest = $nest

#For convenience: switch variables for disabling forces:
var master_disable = false
var seek_disable = false
var separation_disable = false
var align_disable = false
var cohesion_disable = false
var random_disable = false
var gravity_disable = false
var wind_disable = false
var friction_disable = false


func _ready():
	screen_dimension = OS.get_window_size()
	
	#creates desired number of boids at random places inside the window
	for i in range(population):
		randomize()
		_create_boid(randf() * screen_dimension.x, randf() * screen_dimension.y)
	#Perlin Noise Setup
	pnoise.seed = randi() % 100

func _physics_process(delta):
	
	#This loops through all boids in the scene and calculates their new velocity based on their situation
	for boid in boid_array:
		current_boid = boid
		var wr = weakref(boid)
		if !wr.get_ref():
			continue
		
		#This yeets le collision box if you so please
		if disable_collision:
			boid.col.disabled = true
		else:
			boid.col.disabled = false
		
		#This gets all relevant variables (e.g. velocity) from the current boid
		_get_variables(boid)
		
		if !master_disable:
			calc_master(boid)
		
		#check if any forces have been calced. if not: do nothing
		if steer != Vector2.ZERO:
			apply_forces()
			#It is important to limit the Velocity. Otherwise the boids will reach light speed in no time...
			boid.set_vel(vel.clamped(max_speed*brake()))
		else:
			continue
		
		# The current boid only gets assigned a new velocity based of their settings and environmental situation.
		# the script that actually moves the boid can be found in its own scene
		update()


func _create_boid(x, y):
	var b = boidscene.instance()
	b.set_global_position(Vector2(x, y))
	boid_array.append(b)
	nest.add_child(b)

func change_population(value):
	var length = boid_array.size()
	if value < boid_array.size():
		for i in range(length-value):
			
			var b = boid_array[boid_array.size()-1]
			var wr = weakref(b)
			if !wr.get_ref():
				return
			#boid_array.erase()
			boid_array.remove(boid_array.size()-1)
			b.queue_free()
	if value > boid_array.size():
		for i in range(value-length):
			_create_boid(randf() * screen_dimension.x, randf() * screen_dimension.y)

#this function returns all relevant variables from the current boid
#it also does some cosmetic stuff like rendering the target.
func _get_variables(boid):
	pos = boid.get_global_position() #most importantly: the new boid's position
	vel = boid.get_vel() #current velocity
	dir = vel.angle() #current direction
	acc = Vector2.ZERO #acceleration is reset to 0
	steer = Vector2.ZERO #same here
	target = get_global_mouse_position() #target position needs to be updated every frame.
	targetsprite.set_global_position(target)
	if seek_factor == 0:
		targetsprite.visible = false
	else:
		targetsprite.visible = true
	flockmates = get_flockmates(boid)

#This builds an Array of frens in the current boid's field of view
func get_flockmates(boid):
	
	var fm = []
	for b in boid_array:
		var wr = weakref(b)
		if !wr.get_ref():
			return
		var bpos = b.get_global_position()
		#check if flockmate is inside the current boid's radius. Also do not check the current boid itself.
		if pos.distance_to(bpos) <= comfort_zone && \
		pos.distance_to(bpos) > 0:
			#check if neighbor is inside the boid's field of view
			var nbdir = (bpos - pos).normalized()
			if nbdir.dot(vel.normalized()) >= field_of_view:
				if b != null:
					fm.append(b)
	
	return fm

func calc_master(boid):
	calc_seek()
	calc_random()
		
	#Cosmetic: If there is a target to seek, boids will look at it
	if seek_factor > 0:
		boid.rotation = (target - pos).angle() - PI/2
	else:
		boid.rotation = dir - PI/2
	
	#check if current boid has any local flockmates before calculating forces
	#because these calculations are quite expensive performancewise
	if flockmates && !flockmates.empty():
		boid.flocking = true
		calc_separation()
		calc_alignment()
		calc_cohesion()
	else:
		boid.flocking = false
	
	calc_gravity()
	calc_wind()

func calc_random():
	if random_factor == 0 or random_disable:
		return
	
	var amount = pnoise.get_noise_2dv(pos)
	
	steer.rotated(amount * PI * random_factor)
	steer += Vector2(amount, amount) * max_speed * random_factor 

func calc_seek():
	if seek_factor == 0 or seek_disable:
		return
	
	if pos.distance_to(target) < target_radius:
		acc = (target - pos).normalized() * max_speed #desired velocity
		steer += (acc - vel)*seek_factor 

# This function allows for some personal space
# It calculates the average Vector AWAY from all local flockmates
func calc_separation():
	if separation_factor == 0 or separation_disable:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	
	acc = -average #notice that minus? That's Repulsion.
	steer += acc * separation_factor

#Alignment finds the average direction all local flockmates are moving.
#Combine this with a pinch of Separation if you want a bird-like movement-pattern
func calc_alignment():
	if alignment_factor == 0 or align_disable:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_vel()
	average /= flockmates.size()
	
	acc = average
	steer += acc * alignment_factor


#Cohesion finds the Vector for the average position of all local flockmates.
#Crank this up if you want your boids to move more streamlined with less traffic jam
func calc_cohesion():
	if cohesion_factor == 0 or cohesion_disable:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	
	acc = average
	steer += acc * cohesion_factor

func calc_gravity():
	if !gravity_disable:
		steer += Vector2(0, max_force*gravity_factor*mass)

func calc_wind():
	if !wind_disable:
		steer += Vector2(max_force*wind_factor/mass, 0)



func brake():
	#This cuts the boid's max_speed, the closer it is to its target.
	#only works if seeking is active. 
	if brake_radius > 0:
		
		if seek_factor > 0 && pos.distance_to(target) < brake_radius:
			if pos.distance_to(target) < PIXEL_RADIUS:
				return 0
			return pos.distance_to(target) / brake_radius
	return 1

#After everything is calculated, add the new direction to the current velocity.
#The steer vector has to be limited, otherwise the movement appears janky and unnatural.
func apply_forces():
	#this force will be stored inside the boid-scene for drawing purposes.
	current_boid.force = steer*master_factor
	
	
	vel += steer.clamped(max_force*master_factor)
	
	#friction gets applied directly to velocity.
	if !friction_disable:
		vel *= 1-friction_factor

func _draw():
	if draw_velocity:
		for b in boid_array:
			draw_line(b.pos, b.pos+b.vel, Color.green)
	
	if draw_force:
		for b in boid_array:
			draw_line(b.pos, b.pos+b.force, Color.red)
	
	if draw_fov:
		if seek_factor > 0:
			draw_circle(target, brake_radius, Color(0.5, 0.5, 0, 0.3))
		draw_circle(target, target_radius, Color(0.5, 0.5, 0, 0.3))



