extends Panel

#This is the menu layout script. 
#There are probably a billion simpler ways to do this but sometimes I just hate myself so much that I do it this way lol
#please don't read this it's embarassing :(

onready var pop_slider = $MarginContainer/VBoxContainer/population/slider
onready var pop_label = $MarginContainer/VBoxContainer/population/value
onready var pop_lock = $MarginContainer/VBoxContainer/population/lock9
onready var mspeed_slider = $MarginContainer/VBoxContainer/max_speed/slider
onready var mspeed_label = $MarginContainer/VBoxContainer/max_speed/value
onready var mspeed_lock = $MarginContainer/VBoxContainer/max_speed/lock8
onready var mforce_slider = $MarginContainer/VBoxContainer/max_force/slider
onready var mforce_label = $MarginContainer/VBoxContainer/max_force/value
onready var mforce_lock = $MarginContainer/VBoxContainer/max_force/lock7
onready var vrad_slider = $MarginContainer/VBoxContainer/view_radius/slider
onready var vrad_label = $MarginContainer/VBoxContainer/view_radius/value
onready var vrad_lock = $MarginContainer/VBoxContainer/view_radius/lock6
onready var vang_slider = $MarginContainer/VBoxContainer/view_angle/slider
onready var vang_label = $MarginContainer/VBoxContainer/view_angle/value
onready var vang_lock = $MarginContainer/VBoxContainer/view_angle/lock5
onready var trad_slider = $MarginContainer/VBoxContainer/target_radius/slider
onready var trad_label = $MarginContainer/VBoxContainer/target_radius/value
onready var trad_lock = $MarginContainer/VBoxContainer/target_radius/lock4
onready var brad_slider = $MarginContainer/VBoxContainer/brake_radius/slider
onready var brad_label = $MarginContainer/VBoxContainer/brake_radius/value
onready var brad_lock = $MarginContainer/VBoxContainer/brake_radius/lock4
onready var mass_slider = $MarginContainer/VBoxContainer/avg_mass/slider
onready var mass_label = $MarginContainer/VBoxContainer/avg_mass/value
onready var mass_lock = $MarginContainer/VBoxContainer/avg_mass/lock3
onready var dcol = $MarginContainer/VBoxContainer/checkboxes/HBoxContainer/check
onready var dvel = $MarginContainer/VBoxContainer/checkboxes/HBoxContainer2/VBoxContainer/HBoxContainer/draw_velocity
onready var dfor = $MarginContainer/VBoxContainer/checkboxes/HBoxContainer2/VBoxContainer/HBoxContainer2/draw_force
onready var dview = $MarginContainer/VBoxContainer/checkboxes/HBoxContainer2/VBoxContainer/HBoxContainer3/draw_fov
onready var master_slider = $MarginContainer/VBoxContainer/master/slider
onready var master_label = $MarginContainer/VBoxContainer/master/value
onready var master_disable = $MarginContainer/VBoxContainer/master/disable2
onready var master_lock = $MarginContainer/VBoxContainer/master/lock2
onready var seek_slider = $MarginContainer/VBoxContainer/seek/slider
onready var seek_label = $MarginContainer/VBoxContainer/seek/value
onready var seek_disable = $MarginContainer/VBoxContainer/seek/disable
onready var seek_lock = $MarginContainer/VBoxContainer/max_speed/lock8
onready var sep_slider = $MarginContainer/VBoxContainer/separate/slider
onready var sep_label = $MarginContainer/VBoxContainer/separate/value
onready var sep_disable = $MarginContainer/VBoxContainer/separate/disable2
onready var sep_lock = $MarginContainer/VBoxContainer/separate/lock2
onready var ali_slider = $MarginContainer/VBoxContainer/align/slider
onready var ali_label = $MarginContainer/VBoxContainer/align/value
onready var ali_disable = $MarginContainer/VBoxContainer/align/disable3
onready var ali_lock = $MarginContainer/VBoxContainer/align/lock3
onready var coh_slider = $MarginContainer/VBoxContainer/cohesion/slider
onready var coh_label = $MarginContainer/VBoxContainer/cohesion/value
onready var coh_disable = $MarginContainer/VBoxContainer/cohesion/disable4
onready var coh_lock = $MarginContainer/VBoxContainer/cohesion/lock4
onready var ran_slider = $MarginContainer/VBoxContainer/random/slider
onready var ran_label = $MarginContainer/VBoxContainer/random/value
onready var ran_disable = $MarginContainer/VBoxContainer/random/disable5
onready var ran_lock = $MarginContainer/VBoxContainer/random/lock5
onready var gra_slider = $MarginContainer/VBoxContainer/gravity/slider
onready var gra_label = $MarginContainer/VBoxContainer/gravity/value
onready var gra_disable = $MarginContainer/VBoxContainer/gravity/disable6
onready var gra_lock = $MarginContainer/VBoxContainer/gravity/lock6
onready var wind_slider = $MarginContainer/VBoxContainer/wind/slider
onready var wind_label = $MarginContainer/VBoxContainer/wind/value
onready var wind_disable = $MarginContainer/VBoxContainer/wind/disable7
onready var wind_lock = $MarginContainer/VBoxContainer/wind/lock7
onready var fri_slider = $MarginContainer/VBoxContainer/friction/slider
onready var fri_label = $MarginContainer/VBoxContainer/friction/value
onready var fri_disable = $MarginContainer/VBoxContainer/friction/disable8
onready var fri_lock = $MarginContainer/VBoxContainer/friction/lock8

onready var show_button = get_node("../showmenu")
onready var hide_button = $MarginContainer/VBoxContainer/Buttons/hidemenu
onready var pause_button = $MarginContainer/VBoxContainer/Buttons/pause
onready var reset_button = $MarginContainer/VBoxContainer/Buttons/restoredefault

#Autonomous Agent-Node
onready var f = get_node("..")

func _ready():
	pop_slider.value = f.population
	mspeed_slider.value = f.max_speed
	mforce_slider.value = f.max_force
	vrad_slider.value = f.comfort_zone
	vang_slider.value = f.field_of_view
	trad_slider.value = f.target_radius
	brad_slider.value = f.brake_radius
	mass_slider.value = f.mass
	dcol.pressed = f.disable_collision
	dvel.pressed = f.draw_velocity
	dfor.pressed = f.draw_force
	dview.pressed = f.draw_fov
	master_slider.value = f.master_factor
	seek_slider.value = f.seek_factor
	sep_slider.value = f.separation_factor
	ali_slider.value = f.alignment_factor
	coh_slider.value = f.cohesion_factor
	ran_slider.value = f.random_factor
	gra_slider.value = f.gravity_factor
	wind_slider.value = f.wind_factor
	fri_slider.value = f.friction_factor
	update_labels()
	
	show_button.connect("pressed", self, "toggle_visible")
	hide_button.connect("pressed", self, "toggle_visible")
	reset_button.connect("pressed", self, "reset")
	pause_button.connect("pressed", self, "pause_boids")
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		toggle_visible()

func update_labels():
	pop_label.set_text(str(pop_slider.value))
	mspeed_label.set_text(str(mspeed_slider.value))
	mforce_label.set_text(str(mforce_slider.value))
	vrad_label.set_text(str(vrad_slider.value))
	vang_label.set_text(str(vang_slider.value))
	trad_label.set_text(str(trad_slider.value))
	brad_label.set_text(str(brad_slider.value))
	mass_label.set_text(str(mass_slider.value))
	master_label.set_text(str(master_slider.value))
	seek_label.set_text(str(seek_slider.value))
	sep_label.set_text(str(sep_slider.value))
	ali_label.set_text(str(ali_slider.value))
	coh_label.set_text(str(coh_slider.value))
	ran_label.set_text(str(ran_slider.value))
	gra_label.set_text(str(gra_slider.value))
	wind_label.set_text(str(wind_slider.value))
	fri_label.set_text(str(fri_slider.value))

func toggle_visible():
	show_button.visible = !show_button.visible
	visible = !visible

func reset():
	pop_lock.pressed = false
	mspeed_lock.pressed = false
	mforce_lock.pressed = false
	vrad_lock.pressed = false
	vang_lock.pressed = false
	trad_lock.pressed = false
	brad_lock.pressed = false
	mass_lock.pressed = false
	master_lock.pressed = false
	seek_lock.pressed = false
	sep_lock.pressed = false
	ali_lock.pressed = false
	coh_lock.pressed = false
	ran_lock.pressed = false
	gra_lock.pressed = false
	wind_lock.pressed = false
	fri_lock.pressed = false
	master_disable.pressed = false
	f.master_disable = false
	seek_disable.pressed = false
	f.seek_disable = false
	sep_disable.pressed = false
	f.seek_disable = false
	ali_disable.pressed = false
	f.align_disable = false
	coh_disable.pressed = false
	f.cohesion_disable = false
	ran_disable.pressed = false
	f.random_disable = false
	gra_disable.pressed = false
	f.gravity_disable = false
	wind_disable.pressed = false
	f.wind_disable = false
	fri_disable.pressed = false
	f.friction_disable = false
	pop_slider.set_editable(true)
	pop_slider.set_value(20)
	mspeed_slider.set_editable(true)
	mspeed_slider.set_value(25)
	mforce_slider.set_editable(true)
	mforce_slider.set_value(1)
	vrad_slider.set_editable(true)
	vrad_slider.set_value(64)
	vang_slider.set_editable(true)
	vang_slider.set_value(0)
	trad_slider.set_editable(true)
	trad_slider.set_value(200)
	brad_slider.set_editable(true)
	brad_slider.set_value(100)
	mass_slider.set_editable(true)
	mass_slider.set_value(1)
	master_slider.set_editable(true)
	master_slider.set_value(1)
	seek_slider.set_editable(true)
	seek_slider.set_value(0)
	sep_slider.set_editable(true)
	sep_slider.set_value(0)
	ali_slider.set_editable(true)
	ali_slider.set_value(0)
	coh_slider.set_editable(true)
	coh_slider.set_value(0)
	ran_slider.set_editable(true)
	ran_slider.set_value(0)
	gra_slider.set_editable(true)
	gra_slider.set_value(0)
	wind_slider.set_editable(true)
	wind_slider.set_value(0)
	fri_slider.set_editable(true)
	fri_slider.set_value(0.01)
	dcol.pressed = false
	f.disable_collision = false
	dvel.pressed = false
	f.draw_force = false
	dfor.pressed = false
	f.draw_force = false
	dview.pressed = false
	f.draw_fov = false
	f.update()
	

func pause_boids():
	get_tree().paused = !get_tree().paused

func _on_maxspeed_value_changed(value):
	f.max_speed = value
	mspeed_label.set_text(str(value))

func _on_maxforce_value_changed(value):
	f.max_force = value
	mforce_label.set_text(str(value))

func _on_vrad_value_changed(value):
	f.comfort_zone = value
	vrad_label.set_text(str(value))

func _on_vang_value_changed(value):
	f.field_of_view = value
	vang_label.set_text(str(value))

func _on_brad_value_changed(value):
	f.brake_radius = value
	brad_label.set_text(str(value))

func _on_check_toggled(button_pressed):
	f.disable_collision = button_pressed

func _on_seek_value_changed(value):
	f.seek_factor = value
	seek_label.set_text(str(value))

func _on_sep_value_changed(value):
	f.separation_factor = value
	sep_label.set_text(str(value))

func _on_ali_value_changed(value):
	f.alignment_factor = value
	ali_label.set_text(str(value))

func _on_coh_value_changed(value):
	f.cohesion_factor = value
	coh_label.set_text(str(value))

func _on_random_value_changed(value):
	f.random_factor = value
	ran_label.set_text(str(value))

func _on_draw_velocity_pressed():
	f.draw_velocity = dvel.pressed

func _on_draw_force_pressed():
	f.draw_force = dfor.pressed

func _on_draw_fov_pressed():
	f.draw_fov = dview.pressed

func _on_pop_value_changed(value):
	f.population = value
	pop_label.set_text(str(value))

func _on_mass_value_changed(value):
	f.mass = value
	mass_label.set_text(str(value))

func _on_master_value_changed(value):
	f.master_factor = value
	master_label.set_text(str(value))

func _on_gra_value_changed(value):
	f.gravity_factor = value
	gra_label.set_text(str(value))

func _on_wind_value_changed(value):
	f.wind_factor = value
	wind_label.set_text(str(value))

func _on_fric_value_changed(value):
	f.friction_factor = value
	fri_label.set_text(str(value))

func _on_trad_value_changed(value):
	f.target_radius = value
	trad_label.set_text(str(value))

#why are you still reading?

func _on_poplock_toggled(button_pressed):
	pop_slider.set_editable(!button_pressed)

func _on_speedlock_toggled(button_pressed):
	mspeed_slider.set_editable(!button_pressed)

func _on_forcelock_toggled(button_pressed):
	mforce_slider.set_editable(!button_pressed)

func _onvradlock_toggled(button_pressed):
	vrad_slider.set_editable(!button_pressed)

func _on_vanglock_toggled(button_pressed):
	vang_slider.set_editable(!button_pressed)

func _on_tradlock_toggled(button_pressed):
	trad_slider.set_editable(!button_pressed)

func _on_bradlock_toggled(button_pressed):
	brad_slider.set_editable(!button_pressed)

func _on_masslock_toggled(button_pressed):
	mass_slider.set_editable(!button_pressed)

func _on_masterlock_toggled(button_pressed):
	master_slider.set_editable(!button_pressed)

func _on_seeklock_toggled(button_pressed):
	seek_slider.set_editable(!button_pressed)

func _on_seplock_toggled(button_pressed):
	sep_slider.set_editable(!button_pressed)

func _on_alilock_toggled(button_pressed):
	ali_slider.set_editable(!button_pressed)

func _on_cohlock_toggled(button_pressed):
	coh_slider.set_editable(!button_pressed)

func _on_ranlock_toggled(button_pressed):
	ran_slider.set_editable(!button_pressed)

func _on_gralock_toggled(button_pressed):
	gra_slider.set_editable(!button_pressed)

func _on_windlock_toggled(button_pressed):
	wind_slider.set_editable(!button_pressed)

func _on_frilock_toggled(button_pressed):
	fri_slider.set_editable(!button_pressed)

func _on_masterdisable_toggled(button_pressed):
	f.master_disable = button_pressed
	seek_disable.pressed = button_pressed
	sep_disable.pressed = button_pressed
	ali_disable.pressed = button_pressed
	coh_disable.pressed = button_pressed
	ran_disable.pressed = button_pressed
	gra_disable.pressed = button_pressed
	wind_disable.pressed = button_pressed
	fri_disable.pressed = button_pressed

func _on_seekdisable_toggled(button_pressed):
	f.seek_disable = button_pressed

func _on_sepdisable_toggled(button_pressed):
	f.separation_disable = button_pressed

func _on_alidisable_toggled(button_pressed):
	f.align_disable = button_pressed

func _on_cohdisable_toggled(button_pressed):
	f.cohesion_disable = button_pressed

func _on_randisable_toggled(button_pressed):
	f.random_disable = button_pressed

func _on_gradisable_toggled(button_pressed):
	f.gravity_disable = button_pressed

func _on_winddisable_toggled(button_pressed):
	f.wind_disable = button_pressed

func _on_fridisable_toggled(button_pressed):
	f.friction_disable = button_pressed
