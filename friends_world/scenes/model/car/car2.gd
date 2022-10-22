extends VehicleBody

############################################################
# behaviour values
var test=0
export var MAX_ENGINE_FORCE = 50
export var MAX_BRAKE_FORCE = 2.5
export var MAX_STEER_ANGLE = 0.3

export var steer_speed = 3.0
var s_speed=0.5
var steer_target = 0.0
var steer_angle = 0.0

############################################################
# Input
var current=0
var current_other=0
export var joy_steering = JOY_ANALOG_LX
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0
export var player_num=2
remote var players={1:0}
var have_player=0
remote var rate=17000
var min_rate=17000
var max_rate=22050
var cha=22050-17000
var time=0
var max_time=3
remote var brake_sound=0
remote var piao_sound=0
func play_brake():
	if brake_sound:
		if !$"audio/brake".playing:
			$"audio/brake".playing=true
	else:
		$"audio/brake".playing=false
	if piao_sound:
		if !$"audio/piao".playing:
			$"audio/piao".playing=true
	else:
		$"audio/piao".playing=false
remote func play_audio():
	if test:return
	if !$"audio/run".playing:
		$"audio/run".playing=true
remote func play_start():
	$"audio/start".playing=false
	$"audio/start".playing=true
remote func players(data):
	players=data
	for key in players:
		if players[key]:
			if key==1:
				if players[key]==Net.id:
					current=1
				else:
					have_player=1
			else:
				have_player=1
			return
	have_player=0
	$"audio/run".playing=false
	pass
func _check_player(id):
	var have = 0
	for key in players:
		if players[key]==id:
			return 0
	for key in players:
		if !players[key]:
			players[key]=id
			have = 1
			break
	return have

func _on_get_on_car():
	if !players[1]:
		players[1] = Net.id
		current = 1
		Function.msg_group("player","_on_get_on_car")
		Function.msg_group("player","add_collision_exception_with",self)
		$camera/camera.current=true
		play_start()
		if Net.status:
			rpc("play_start")
		
	else:
		if _check_player(Net.id):
			current_other=1
			Function.msg_group("player","_on_get_on_car_other")
			Function.msg_group("player","add_collision_exception_with",self)
#	if current_other:
#		if _check_player(Net.id):
#			Function.msg_group("player","_on_get_on_car_other")
#			Function.msg_group("player","add_collision_exception_with",self)
#
#	else:
#		if !players[1]:
#			players[1] = Net.id
#			current = 1
#			rset(current,1)
#			Function.msg_group("player","_on_get_on_car")
#			Function.msg_group("player","add_collision_exception_with",self)
#			$camera.current=true
#		else:
#			if _check_player(Net.id):
#				Function.msg_group("player","_on_get_on_car_other")
#				Function.msg_group("player","add_collision_exception_with",self)
#				current_other=1
#				rset(current_other,1)
	players(players)
	if Net.status:
		rpc("players",players)
func _on_get_off_car():
	if Net.status:
		#我不是开车的下车
		if players[1] != Net.id:
			for key in players:
				if players[key]==Net.id:
					players[key] = 0
					Function.msg_group("player","_on_get_off_car_other")
					Function.msg_group("player","remove_collision_exception_with",self)
					players(players)
					rpc("players",players)
					current_other = 0
			return
	current_other = 0
	players[1] = 0
	players(players)
	if Net.status:
		rpc("players",players)
	current=0
	Function.msg_group("player","_on_get_off_car")
	Function.msg_group("player","remove_collision_exception_with",self)
	Function.msg_group("player","_update_camera")
	$camera/camera.current=false
func _on_get_on_car_other(id):
	print("_on_get_on_car_other",id)
	have_player=1
#	current_other = 1
	Function.msg_group(str(id),"_on_get_on_car")
	Function.msg_group(str(id),"add_collision_exception_with",self)
#	Function.msg_group("player_node","_forward_1","add_collision_exception_with",Net.id,self)
func _on_get_off_car_other(id):
	Function.msg_group(str(id),"_on_get_off_car")
	Function.msg_group(str(id),"remove_collision_exception_with",self)
#	for key in players:
#		if players[key]==id:
#			players[key]=0
#			rpc("players",players)
#	if players["1"]:
#		return
#	current_other = 0
#	engine_force=0
#	brake=0
#	steering=0
remote func _light(status):
	if status:
		$light.show()
	else:
		$light.hide()
remote func play_horn():
	$audio/horn.play()
func _on_event(id):
	print(id)
	if Net.status:
		if Net.id == id:
			_on_get_on_car()
		else:
			_on_get_on_car_other(id)
	else:
		_on_get_on_car()
#车
master func send_data_car(id):
	rset_id(id,"shadow",shadow)
	rset_id(id,"brake_sound",brake_sound)
	rpc_id(id,"players",players)
func _ready():
	for i in range(10):
		if has_node('p'+str(i+1)):
			player_num=i+1
	for i in range(player_num):
		players[i+1]=0
	shadow.tr=translation
	shadow.rot=rotation_degrees
	$"audio/run".stream=$"audio/run".stream.duplicate()
	audio_run=$"audio/run".stream
	add_to_group("car")
	set_process_input(true)
	$time.connect("timeout",self,"_timeout")
	if Net.status:
		if Net.id!=1:
			rpc_id(1,"send_data_car",Net.id)
	pass
onready var audio_run=$"audio/run".stream
var c=0
var mouse_speed = 0.1
func _input(event):
	if !current:return
	if Overall.gui:return
	if event is InputEventMouseMotion:
		var camera=$camera/camera
		var camera_rot=camera.rotation_degrees
#		$camera.rotate_x(deg2rad(event.relative.y * mouse_speed))
#		camera.rotation_degrees.x+=event.relative.y * mouse_speed * -1
		camera.rotate_y(deg2rad(event.relative.x * mouse_speed * -1))
#		if camera.rotation_degrees.x<-60||camera.rotation_degrees.x>60:
#			camera.rotation_degrees.x=camera_rot.x
		if camera.rotation_degrees.y<-40||camera.rotation_degrees.y>40:
			camera.rotation_degrees.y=camera_rot.y
	if event.is_action_pressed("z"):
		play_horn()
		if Net.status:
			rpc("play_horn")
		
	if event.is_action_pressed("c"):
		var light=0
		if !$light.visible:
			light=1
		_light(light)
		if Net.status:
			rpc("_light",light)
	if event.is_action_pressed("f5"):
		if $camera/camera.current:
			$camera/camera.current=false
			$camera/camera_h.current=true
		else:
			$camera/camera.current=true
			$camera/camera_h.current=false
func _timeout():
	c+=1
	if c>3:
		c=0
		brake_sound=0
		piao_sound=0
	if have_player||current||current_other:
		audio_run.mix_rate=rate
	
remote var shadow={
	"engine_force":0,
	"brake":0,
	"steering":0,
	"tr":Vector3(),
	"rot":Vector3()
}
var _time=0
var _time_max=1
func _get_off_car():
	_on_get_off_car()
	Function.msg_group("plane","_forward_1","_on_get_off_car_other",Net.id,get_path(),Net.id)
func _process(delta):
	if have_player||current:
		play_audio()
	else:
		$"audio/run".playing=false
	if have_player:
		play_brake()
		if !current:
			engine_force=shadow.engine_force
			brake=shadow.brake
			steering=shadow.steering
			_time+=delta
			if _time>_time_max:
				_time=0
				var offset = translation-shadow.tr
				if offset>Vector3(1,1,1)||offset<Vector3(-1,-1,-1):
					translation=shadow.tr
					rotation_degrees=shadow.rot
		for key in players:
			if players[key]:
				if players[key]==Net.id:
					if key == 1:
						Function.msg_group("player","_set_pos",get_node("p"+str(key)).global_transform.origin,rotation_degrees)
					else:
						Function.msg_group("player","_set_pos_other",get_node("p"+str(key)).global_transform.origin)

				else:
					if key == 1:
						Function.msg_group(str(players[key]),"_set_pos",get_node("p"+str(key)).global_transform.origin,rotation_degrees)
					else:
						Function.msg_group(str(players[key]),"_set_pos_other",get_node("p"+str(key)).global_transform.origin)
	if current_other:
		#f
		if Input.is_action_pressed("f"):
			_on_get_off_car()
			
			Function.msg_group("plane","_forward_1","_on_get_off_car_other",Net.id,get_path(),Net.id)
		return
	if !current||test:return
	if Input.is_action_pressed("f"):
		_on_get_off_car()
		Function.msg_group("plane","_forward_1","_on_get_off_car_other",Net.id,get_path(),Net.id)
	rate=min_rate+time*cha/max_time
	if rate>max_rate:
		rate=max_rate
	play_audio()
	if Net.status:
		shadow={"engine_force":engine_force,"brake":brake,"steering":steering,"tr":translation,"rot":rotation_degrees}
		for i in Net.player_info:
			if i != Net.id:
				rset_unreliable_id(i,"rate",rate)
				rset_unreliable_id(i,"shadow",shadow)
	for key in players:
			if players[key]:
				if players[key]==Net.id:
					Function.msg_group("player","_set_pos",$p1.global_transform.origin,rotation_degrees)
				else:
					Function.msg_group(str(players[key]),"_set_pos_other",get_node("p"+str(key)).global_transform.origin)
				
#	for key in players:
#		if players[key]&&key!=1:
#			Function.msg_group("player_node","_on_set_pos_solve",translation+get_node("p"+str(key)).translation,rotation_degrees,players[key])
#			Function.msg_group("player_node","_set_pos",players[key],translation+get_node("p"+str(key)).translation,rotation_degrees,players[key])
	
#	var steer_val = steering_mult * Input.get_joy_axis(0, joy_steering)
#	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
#	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	var steer_val=0
	var throttle_val=0
	var brake_val=0
	# overrules for keyboard
	if Input.is_action_pressed("w"):
		time+=delta
		if time>max_time:
			time=max_time
		throttle_val = 1.0
	else:
		time-=delta*3
		if time<0:
			time=0
	if Input.is_action_pressed("s"):
		throttle_val = -s_speed
	if Input.is_action_pressed("a"):
		steer_val = 1.0
	elif Input.is_action_pressed("d"):
		steer_val = -1.0
	brake_sound=0
	piao_sound=0
	if Input.is_action_pressed("shift"):
		brake_val = 0.1
		throttle_val=0
		if linear_velocity>Vector3(1,1,1)||linear_velocity<Vector3(-1,-1,-1):
			piao_sound=1
	if Input.is_action_pressed("jump"):
		piao_sound=0
		brake_val = 1
		throttle_val=0
		if linear_velocity>Vector3(1,1,1)||linear_velocity<Vector3(-1,-1,-1):
			brake_sound=1
	if Net.status:
		for i in Net.player_info:
			if i != Net.id:
				rset_unreliable_id(i,"piao_sound",piao_sound)
				rset_unreliable_id(i,"brake_sound",brake_sound)
	play_brake()
	engine_force = throttle_val * MAX_ENGINE_FORCE
	brake = brake_val * MAX_BRAKE_FORCE
	steer_target = steer_val * MAX_STEER_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	steering = steer_angle
	