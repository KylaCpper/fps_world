extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var touch_dic=1.6

var touch_dic_h=1.7
var touch_dic_f=1.6
var hp=100
var kill=0
var dead=0
var speed=2
onready var camera=$Camera
onready var neck=$Armature/Skeleton/neck
var mouse_speed=0.1
const GRAVITY=5
var jump_speed=25
var air_time_max=8
var vec3=Vector3()
var air_time=0
var air_max=0.5
var allow_jump=1
var allow_jump_=1
var money=0
var bullet=8
var bullet_max=8
var bullet_z=32

var gun_tscn=Overall.tscn.gun
var chest_bone=Overall.chests[Net.my_info.model]
var stop_bones=Overall.stop_bones[Net.my_info.model]
var handheld=Overall.handhelds[Net.my_info.model]
var materials=Overall.materials
var rest=null
var clip_first=1

var place_time_max=0.3
var place_time=0

var block_id=0
var blocks_id=[3,4,7,8,9,10,11,12,13]
var blocks_scene=[
	load("res://scenes/meshlib/block/block_scene/grass.tscn"),
	load("res://scenes/meshlib/block/block_scene/dirt.tscn"),
	load("res://scenes/meshlib/block/block_scene/stone.tscn"),
	load("res://scenes/meshlib/block/block_scene/leaf.tscn"),
	load("res://scenes/meshlib/block/block_scene/leaf_dead.tscn"),
	load("res://scenes/meshlib/block/block_scene/sand.tscn"),
	load("res://scenes/meshlib/block/block_scene/snow.tscn"),
	load("res://scenes/meshlib/block/block_scene/wood_board.tscn"),
	load("res://scenes/meshlib/block/block_scene/glass.tscn")
]
var blocks_id_length=blocks_id.size()-1

var crack_scene=load("res://scenes/meshlib/block/block_scene/crack/crack.tscn")

var camera_fov_speed=3
var car_other=0
var car=0
func _update_camera():
	camera.current=false
	camera.current=true
func _on_get_off_car():
	translation.y+=2
	_change_camera(0)
	car=0
	rotation_degrees=Vector3()
func _on_get_on_car():
	$Camera.visible=false
	$Armature.visible=true
	car=1
func _on_get_on_car_other():
	car_other=1
func _on_get_off_car_other():
	translation.y+=2
	car_other=0
	rotation_degrees=Vector3()
func _set_pos(tr,rot):
	translation=tr
	rotation_degrees=rot
	if Net.status:
		$"../"._set_pos(Net.id,tr,rot)
func _set_pos_other(tr):
	translation=tr
func _enter_tree():
	var time = Timer.new()
	time.one_shot=true
	time.wait_time=1.8
	time.set_name("clip_time")
	add_child(time)
var this={}
func spot(be):
	$Armature/Skeleton/head/spot.visible=be
	$Camera/head/spot.visible=be
func create_car(car):
	Function.msg_group("plane","create_car",car,translation)
func _ready():
	$Camera/ray.add_exception(self)
	$Camera_h/Camera_h/ray.add_exception(self)
	Function.msg_group("2d","_money",Net.my_info.money)
	$Armature/Skeleton/head/spot.scale=Vector3(handheld/10,handheld/10,handheld/10)
	spot(0)
	$clip_time.connect("timeout",self,"_clip_sound")
	
	if Net.my_info.model==0||Net.my_info.model==3:
		var m0=$Armature/Skeleton/neck/head.get_surface_material(0).duplicate()
		$Armature/Skeleton/neck/head.set_surface_material(0,m0)
		$Armature/Skeleton/body.set_surface_material(0,m0)
		$Armature/Skeleton/left_arm.set_surface_material(0,m0)
		$Armature/Skeleton/right_arm.set_surface_material(0,m0)
	elif Net.my_info.model==1:
		this["m0"]=$Armature/Skeleton/neck/head.get_surface_material(0).duplicate()
		this["m1"]=$Armature/Skeleton/neck/head.get_surface_material(1).duplicate()
		this["m2"]=$Armature/Skeleton/neck/head.get_surface_material(2).duplicate()
		this["m3"]=$Armature/Skeleton/neck/head.get_surface_material(3).duplicate()
		for i in materials[Net.my_info.model][1]:
			$Armature/Skeleton/body.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.my_info.model][0]:
			$Armature/Skeleton/neck/head.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.my_info.model][2]:
			$Armature/Skeleton/left_arm.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.my_info.model][3]:
			$Armature/Skeleton/right_arm.set_surface_material(i,this["m"+str(i)])
	else:
		this["h7"]=$Armature/Skeleton/neck/head.get_surface_material(7).duplicate()
		this["h26"]=$Armature/Skeleton/neck/head.get_surface_material(26).duplicate()
		this["h27"]=$Armature/Skeleton/neck/head.get_surface_material(27).duplicate()
		this["b0"]=$Armature/Skeleton/body.get_surface_material(0).duplicate()
		this["b3"]=$Armature/Skeleton/body.get_surface_material(3).duplicate()
		this["b6"]=$Armature/Skeleton/body.get_surface_material(6).duplicate()
		this["b11"]=$Armature/Skeleton/body.get_surface_material(11).duplicate()
		this["b17"]=$Armature/Skeleton/body.get_surface_material(17).duplicate()
		for i in materials[Net.my_info.model][1]:
			$Armature/Skeleton/body.set_surface_material(i,this["h"+str(i)])
		for i in materials[Net.my_info.model][0]:
			$Armature/Skeleton/neck/head.set_surface_material(i,this["b"+str(i)])
		for i in materials[Net.my_info.model][2]:
			$Armature/Skeleton/left_arm.set_surface_material(i,this["b11"])
		for i in materials[Net.my_info.model][3]:
			$Armature/Skeleton/right_arm.set_surface_material(i,this["b11"])
	rest=$Armature/Skeleton.get_bone_pose(chest_bone)
	_change_gun(0)
	_change_camera(0)
	$Armature/hp/Viewport/hp.max_value=100
	$Armature/hp/Viewport/hp.value=hp
	Function.msg_group("2d","_hp",hp)
	
	$Armature/hp.visible=false
	
	add_to_group("player")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process_input(true)
	$attack_time.connect("timeout",self,"_on_attack_")
	pass
func _on_action(event,e,name):
	if event.is_action_pressed(e):
		if !$AnimationPlayer.has_animation(name):return
		if Net.status:
			$"../"._on_action(Net.id,name)
		if $AnimationPlayer.current_animation==name:
			if $AnimationPlayer.is_playing():
				return
		$AnimationPlayer.play(name)
func _msg(text):
	$msg._show(text)
var time=0
var double_key_time=0 
var move_key=""
var run=0
func _on_build():
	$AnimationTreePlayer.oneshot_node_start("event")
	$hand.play("event")
	check_ray(0,0,1)
func _process(delta):
	if car:return
	double_key_time+=delta
	if double_key_time>=0.3:
		move_key=""
		double_key_time=0
		
	vec3.y-=GRAVITY*delta
	vec3.x=0
	vec3.z=0
	var w=Input.is_action_pressed("w")
	var s=Input.is_action_pressed("s")
	var a=Input.is_action_pressed("a")
	var d=Input.is_action_pressed("d")
	var jump=Input.is_action_pressed("jump")
	if car_other:
		w=0
		s=0
		a=0
		d=0
		jump=0
	if !allow_jump_:
		if !jump:
			allow_jump=0
	if jump:
		allow_jump_=0
	if !allow_jump:
		jump=0
	if Overall.gui:
		w=0
		s=0
		a=0
		d=0
		jump=0
	else:
		if Input.is_action_pressed("mouse_left"):
			if !gun&&!Overall.gui:
				_on_attack()
		if Input.is_action_pressed("mouse_right"):
			if !gun&&!Overall.gui:
				if(place_time==0):
					_on_build()
				place_time+=delta
				if(place_time>place_time_max):
					place_time=0
		else:
			place_time=0
				
#			if gun:
#				_on_shot()
#			else:
#				_on_attack()
	if w||s||a||d:
		if run:
			$AnimationTreePlayer.blend2_node_set_amount("walk_mode",1)
		else:
			$AnimationTreePlayer.blend2_node_set_amount("walk_mode",0)
		$AnimationTreePlayer.timescale_node_set_scale("walk_speed",1)
		$AnimationTreePlayer.blend2_node_set_amount("stop",0)
		if !$AnimationPlayer.is_playing():
			if run:
				$AnimationPlayer.play("move_sound",-1,2)
			else:
				$AnimationPlayer.play("move_sound")
				
		
	else:
		if $AnimationPlayer.current_animation=="move_sound":
			if $AnimationPlayer.is_playing():
				$AnimationPlayer.stop()
		$AnimationTreePlayer.timescale_node_set_scale("walk_speed",0)
		$AnimationTreePlayer.blend2_node_set_amount("stop",1)
		#$AnimationPlayer.play("stop")
		
	var body_rot=0
	if w:
		vec3.z+=speed*(run+1)
	if s:
		vec3.z-=speed/2
	if a:
		body_rot-=45
		vec3.x+=speed
	if d:
		body_rot+=45
		vec3.x-=speed
	#针对不同模型
	if Net.my_info.model==2:
		#雷姆
		$Armature/Skeleton.rotation_degrees.y=-body_rot
		if gun:
			chest.z=deg2rad(-body_rot)
			set_bone_rot(chest_bone,chest)
		else:
			neck.rotation_degrees.y=body_rot
	else:
		#默认
		$Armature/Skeleton.rotation_degrees.z=body_rot
		if gun:
			chest.z=deg2rad(-body_rot)
			set_bone_rot(chest_bone,chest)
		else:
			neck.rotation_degrees.z=-body_rot
	if jump&&air_time<=air_max:
		if air_time==0:
			_move_sound()
		air_time+=delta
		vec3.y=(air_time_max-air_time*air_time_max)*jump_speed*delta
	vec3=move_and_slide(get_global_transform().basis.xform(vec3),Vector3(0,1,0))
	Function.msg_group("world","_change_tran",translation)
	if Net.status:
		get_node("../").shadow(Net.id,{"pos":translation,"body":body_rot,"run":run,"gun":gun})
		#get_node("../").rpc_unreliable("shadow",get_tree().get_network_unique(),{"pos":translation,"rot":rotation})
	if is_on_floor():
		allow_jump=1
		allow_jump_=1
		air_time=0
		vec3.y=0
	if test_move(transform,Vector3(0,-0.4,0)):
		$AnimationTreePlayer.blend2_node_set_amount("jump",0)
		if gun:
			$AnimationTreePlayer.mix_node_set_amount("gun",1)
	else:
		$AnimationTreePlayer.blend2_node_set_amount("jump",1)
		if gun:
			$AnimationTreePlayer.mix_node_set_amount("gun",0)
		
	_input=0
	
	pass
func _check_run(key):
	double_key_time=0
	if move_key==key&&key!="":
		run=1
	else:
		run=0
	move_key=key
var _input=0

func _on_attack():
	if Net.status:
		$"../"._on_attack(Net.id)
	if !$AnimationTreePlayer.oneshot_node_is_active("attack"):
		$AnimationTreePlayer.oneshot_node_start("attack") 
		$hand.play("attack")
		$attack_time.start()
func _on_shot():
	if $clip_time.time_left!=0:return
	if bullet>0:
		bullet-=1
		Function.msg_group("2d","_bullet",bullet,bullet_z)
	else:
		_on_change_clip()
		return
	if Net.status:
		$"../"._on_shot(Net.id)
	
	
	$audio/shot0.play()
	var obj=check_ray(1,gun)
	var vec3=camera.get_node("ray").get_collision_point()
	$"../gun".translation=vec3
	$"../blood".translation=vec3
	$Armature/Skeleton/hand/gun._on_shot(vec3)
	$Camera/right_arm/hand/gun._on_shot(vec3)
		#$Armature/Skeleton/hand/gun._on_shot(camera.project_position(get_viewport().get_mouse_position()))
	if obj!=null:
		var hurt_hp=30
		if obj.get_parent().name=="player_node":
			if obj.name=="CollisionShape4":
				hurt_hp=100
			if obj.name=="CollisionShape6"||obj.name=="CollisionShape7":
				hurt_hp=15
			if obj.name=="CollisionShape"||obj.name=="CollisionShape2":
				hurt_hp=20
			if obj.name=="CollisionShape3":
				hurt_hp=30
			$"../"._on_hurt(int(obj.name),Net.id,translation,hurt_hp)
			$"../blood".restart()
			#obj._on_hurt(int(obj.name),Net.id,translation)
		elif obj.get_parent().name=="enemy_node":
			$"../../enemy_node"._on_hurt(obj.name,Net.id,translation,hurt_hp)
			$"../blood".restart()
		else:
			$"../gun".restart()
			if obj.has_method("_on_hurt"):
				$"../../plane"._on_hurt(Net.id,obj)
#	if !$AnimationTreePlayer.oneshot_node_is_active("attack"):
#		$AnimationTreePlayer.oneshot_node_start("attack") 
#		$attack_time.start()
func _on_hurt(_id,id_,tran,num):
	if hp<=0:return
	Function.msg_group("2d","_on_hurt")
	Net.my_info.hp-=num
	Net.player_info[_id].hp-=num
	hp-=num
	$Armature/hp/Viewport/hp.value=hp
	Function.msg_group("2d","_hp",hp)
	if hp<=0:
		_on_dead(_id,id_)
	else:
		$AnimationTreePlayer.oneshot_node_start("hurt")
		$AnimationPlayer.play("hurt_effect")
		
	$audio/hurt.play()
	var tran_=tran-translation
	move_and_slide(Vector3(tran_.x,20,tran_.z),Vector3(0,1,0))
func _on_add_money(num):
	Net.my_info.money+=num
	Function.msg_group("2d","_money",Net.my_info.money)
func _on_dead(_id,id_):
	var id_name
	if typeof(id_)!=TYPE_INT:
		id_name=id_
	else:
		id_name=Net.player_info[id_].name
		Net.player_info[id_].kill+=1
	$"../"._on_dead(_id,id_)
	Function.msg_group("car","_get_off_car")
	
	#Net.player_info[id_].money+=10
	Net.player_info[_id].dead+=1
	_on_dead_num(_id,id_)
	var text=id_name+" "+tr("killed")+" "+Net.player_info[_id].name
	Function.msg_group("msg","_add_text",text,"yellow")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("dead")
	Function.msg_group("2d","_on_dead")
func _on_dead_num(_id,id_):
	if typeof(id_)==TYPE_INT:
		if Net.player_info[id_].kill%10==0:
			var kill=Net.player_info[id_].name+" "+tr("a_killed")+str(Net.player_info[id_].kill)+tr("a_people")
			Function.msg_group("msg","_add_text",kill,"yellow")
	if Net.player_info[_id].dead%10==0:
		var dead=Net.player_info[_id].name+" "+tr("a_dead")+str(Net.player_info[_id].dead)+tr("frequency")
		Function.msg_group("msg","_add_text",dead,"yellow")
func _on_new_life():
	hp=100
	$Armature/hp/Viewport/hp.value=hp
	Function.msg_group("2d","_hp",hp)
	$AnimationPlayer.play("new_life")
	
	translation=Vector3(-18,2,-31)
func _on_attack_():
	$audio/hueiwu.play()
	var obj=check_ray(1)
	if obj!=null:
		var vec3=camera.get_node("ray").get_collision_point()
		$"../gun".translation=vec3
		$"../blood".translation=vec3
		
		if obj.get_parent().name=="player_node":
			$"../"._on_hurt(int(obj.name),Net.id,translation,20)
			$"../blood".restart()
			#obj._on_hurt(int(obj.name),Net.id,translation)
		elif obj.get_parent().name=="enemy_node":
			$"../../enemy_node"._on_hurt(obj.name,Net.id,translation,20)
			$"../blood".restart()
		else:
			$"../gun".restart()
			if obj.has_method("_on_hurt"):
				$"../../plane"._on_hurt(Net.id,obj)
			else:
				$audio/hurt.play()
func set_bone_rot(id, ang):
	if Net.my_info.model==1:
		ang=-ang
	var newpose = rest.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	$Armature/Skeleton.set_bone_pose(id, newpose)
var gun=0
var chest=Vector3()
var sp=0
func change_block():
	var block_scene=blocks_scene[block_id].instance()
	block_scene.name="block"
	block_scene.visible=true
	$Armature/Skeleton/hand/block.add_child(block_scene)
	block_scene=blocks_scene[block_id].instance()
	block_scene.name="block"
	block_scene.visible=true
	$Camera/right_arm/hand/block.add_child(block_scene)
func _change_hand():
	if has_node("Armature/Skeleton/hand/block/block"):
		$Armature/Skeleton/hand/block/block.free()
		$Camera/right_arm/hand/block/block.free()
	if !gun:
		call_deferred("change_block")
		
func _input(event):
	if car:return
	#拿枪
	if gun:
		if event.is_action_pressed("mouse_left")&&!Overall.gui:
			_on_shot()
		if event.is_action_pressed("r"):
			_on_change_clip()
	else:
		#不拿枪换方块
		var mouse_down=event.is_action_pressed("mouse_down")
		var mouse_up=event.is_action_pressed("mouse_up")
		if mouse_down:
			if block_id<blocks_id_length:
				block_id+=1
			else:
				block_id=0
		if mouse_up:
			if block_id>0:
				block_id-=1
			else:
				block_id=blocks_id_length
		if mouse_down||mouse_up:
			if Net.status:
				$"../"._forward_1("_change_hand",Net.id,block_id)
			_change_hand()
			
	if event.is_action_pressed("2"):
		#x45 down left z45
		set_bone_rot(2,Vector3(deg2rad(45),0,0))
	if event.is_action_pressed("1"):
		if Net.status:
			$"../"._forward_1("_change_gun",Net.id,1)
		_change_gun(1)
	if event.is_action_pressed("3"):
		if Net.status:
			$"../"._forward_1("_change_gun",Net.id,0)
		_change_gun(0)
	
	if event.is_action_pressed("f"):
		sp=!sp
		if Net.status:
			$"../"._forward_1("spot",Net.id,sp)
		spot(sp)
	_on_action(event,"f1","hi")
	_on_action(event,"f2","hello")
	_on_action(event,"f3","excited")
	_on_action(event,"f4","problem")
	_on_action(event,"f6","angry")
	_on_action(event,"f7","v_excited")
	_on_action(event,"f8","sex")
	if event.is_action_pressed("f5"):
		_change_camera(1)
	if event is InputEventMouseMotion and !Overall.gui:
		if gun:
			chest.x+=deg2rad(event.relative.y * mouse_speed)
			self.rotate_y(deg2rad(event.relative.x * mouse_speed * -1))
			chest.x = clamp(chest.x, -1, 1)
			set_bone_rot(chest_bone,chest)
		
		var neck_rot = neck.rotation_degrees
		var camera_rot=$Camera.rotation_degrees
		var camera_h_rot=$Camera_h.rotation_degrees
		if !gun:
			neck.rotation_degrees.x+=event.relative.y * mouse_speed
		$Camera.rotate_x(deg2rad(event.relative.y * mouse_speed))
		$Camera_h.rotate_x(deg2rad(event.relative.y * mouse_speed))
		
		self.rotate_y(deg2rad(event.relative.x * mouse_speed * -1))
		if $Camera.rotation_degrees.x<-80||$Camera.rotation_degrees.x>80:
			neck.rotation_degrees=neck_rot
			$Camera.rotation_degrees=camera_rot
			$Camera_h.rotation_degrees=camera_h_rot
		
		_input=1
		if Net.status:
			get_node("../").shadow(Net.id,{"chest":chest,"rot":rotation_degrees,"neck":neck.rotation_degrees,"camera":camera_rot,"camera_h":camera_h_rot})
	if event.is_action_pressed("mouse_up"):
		if $Camera_h/Camera_h.current==true:
			if $Camera_h/Camera_h.fov<100:
				$Camera_h/Camera_h.fov+=camera_fov_speed
		
	if event.is_action_pressed("mouse_down"):
		if $Camera_h/Camera_h.current==true:
			if $Camera_h/Camera_h.fov>50:
				$Camera_h/Camera_h.fov-=camera_fov_speed
		
	if event.is_action_pressed("w"):
		_check_run("w")
	if event.is_action_released("w"):
		if run:
			_check_run("")
	if event.is_action_pressed("e"):
		var obj=check_ray()
		if Net.status:
			$"../"._on_event(Net.id)
		$AnimationTreePlayer.oneshot_node_start("event")
		$hand.play("event")
		if obj!=null:
			if obj.has_method("_on_event"):
				var p_name=obj.get_parent().name
				if p_name!="player_node"&&p_name!="enemy_node":
					$"../../plane"._on_event(Net.id,obj)
func _on_change_clip():
	if bullet<bullet_max&&bullet_z>0:
		if $clip_time.time_left!=0:return
		_clip_sound()
		$clip_time.wait_time=1.8
		$clip_time.start()
		if Net.status:
			$"../"._forward("_on_change_clip",Net.id)
		$Armature/Skeleton/hand/gun._on_change_clip()
		$Camera/right_arm/hand/gun._on_change_clip()
		$AnimationTreePlayer.oneshot_node_start("clip")
		$hand.play("clip")
func _clip_sound():
	var id =0
	if !clip_first:
		id=1
	get_node("audio/clip"+str(id)).play()
	if !clip_first:
		var sub=bullet_max-bullet
		if bullet_z-sub>=0:
			bullet_z-=sub
			bullet=bullet_max
		else:
			bullet+=bullet_z
			bullet_z=0
			
		Function.msg_group("2d","_bullet",bullet,bullet_z)
	clip_first=!clip_first
var cur_c=["Camera","Camera_h/Camera_h","Camera_f"]
var cur_c_i=0
func _change_camera(num):
	cur_c_i+=num
	
	if cur_c_i>=3:
		cur_c_i=0
	#主场景
	if cur_c_i==0:
		camera=$Camera
		$"../"._forward_1("_on_change_camera",Net.id,"Camera")
		touch_dic=touch_dic_f
		$Camera.visible=true
		$Armature.visible=false
	#后第三人称
	elif cur_c_i==1:
		camera=$Camera_h/Camera_h
		$"../"._forward_1("_on_change_camera",Net.id,"Camera_h/Camera_h")
		touch_dic=touch_dic_h
		$Camera.visible=false
		$Armature.visible=true
	for data in cur_c:
		if data==cur_c[cur_c_i]:
			get_node(data).current=1
		else:
			get_node(data).current=0
func _change_gun(mode):
	gun=mode
	if Net.status:
		$"../"._forward_1("_change_hand",Net.id,block_id)
	_change_hand()
	if gun:
		if !has_node("Armature/Skeleton/hand/gun"):
			#camera=$Armature/Skeleton/head/Camera
			#cur_c[0]="Armature/Skeleton/head/Camera"
			_change_camera(0)
			var gun_scene=gun_tscn[0].instance()
			gun_scene.name="gun"
			gun_scene.scale=Vector3(handheld,handheld,handheld)
			$Armature/Skeleton/hand.add_child(gun_scene)
			
			gun_scene=gun_tscn[0].instance()
			gun_scene.name="gun"
			$Camera/right_arm/hand.add_child(gun_scene)
			
			for data in stop_bones:
				$AnimationTreePlayer.blend2_node_set_filter_path ("stop","Armature/Skeleton:"+data,true)
			for i in range(1,5):
				$AnimationTreePlayer.mix_node_set_amount("hand"+str(i),0)
			$AnimationTreePlayer.mix_node_set_amount("gun",1)
			
			$hand.play("gun0")
			neck.rotation_degrees=Vector3()
	else:
		if has_node("Armature/Skeleton/hand/gun"):
			#camera=$Armature/Skeleton/neck/Camera
			#cur_c[0]="Armature/Skeleton/neck/Camera"
			_change_camera(0)
			$Camera/right_arm/hand/gun.queue_free()
			$Armature/Skeleton/hand/gun.queue_free()
			
			var offset=1
			if Net.my_info.model==1:
				offset=0.8
			for data in stop_bones:
				$AnimationTreePlayer.blend2_node_set_filter_path ("stop","Armature/Skeleton:"+data,false)
			for i in range(1,5):
				$AnimationTreePlayer.mix_node_set_amount("hand"+str(i),offset)
			$AnimationTreePlayer.mix_node_set_amount("gun",0)
			
			$hand.play("hand")
			chest=Vector3()
			set_bone_rot(chest_bone,chest)

func check_ray(hurt=0,gun=0,right=0):
	var ray=camera.get_node("ray")
	if gun:
		ray.cast_to.z=3000
	elif right:
		ray.cast_to.z=5
	else:
		ray.cast_to.z=1
	if cur_c_i==1:
		ray.cast_to.z+=1.4
	ray.force_raycast_update()
	if(ray.is_colliding()):
		var obj=ray.get_collider()
		#放置方块
		if(right==1):
			_play_event()
			var offset=ray.get_collision_normal()
			var pos = ray.get_collision_point()
			if pos.distance_to(translation)>touch_dic:
				if obj.name=="block":
					if offset.x>0:offset.x=0
					if offset.y<0:offset.y=0
					if offset.z>0:offset.z=0
				var block_pos=pos+offset
				if Net.status:
					$"../"._forward_2("_on_build",block_pos,blocks_id[block_id])
				$"../../plane"._on_build(block_pos,blocks_id[block_id],name)
			return null
		#破坏方块
		elif hurt:
			var offset=ray.get_collision_normal()
			var pos = ray.get_collision_point()
			if obj.name=="block":
				if offset.x<0:offset.x=0
				if offset.y>0:offset.y=0
				if offset.z<0:offset.z=0
				var block_pos=pos+offset
				var pos3=obj.world_to_map(block_pos)
				#获取方块在世界位置
				if check_crack(pos3):
					var block_id_be = obj.get_cell_item(pos3[0],pos3[1],pos3[2])
					if Net.status:
						$"../"._forward_2("_on_damage",block_pos,blocks_id[block_id])
					$"../../plane"._on_damage(block_pos,blocks_id[block_id],name)
				
#			if Net.status:
#				$"../"._forward_2("_on_build",block_pos,blocks_id[block_id])
#			$"../../plane"._on_build(block_pos,blocks_id[block_id],name)
			pass
			
		if(!obj.is_queued_for_deletion()):
			if obj.has_method("world_to_map"):
				var offset=ray.get_collision_point()
				if obj.name=="road":
					offset+=+Vector3(28.5,-0.9,31.5)
				else:
					offset*=3.333
					offset+=+Vector3(5,7.5+3.6,5)
					var pos3=obj.world_to_map(offset)
					var id = obj.get_cell_item(pos3[0], pos3[1], pos3[2])
					if id!=-1:
						var obj_name = obj.theme.get_item_name(id)
						if hurt&&!gun:
							if obj_name=="ground0":
								$audio/grass.play()
							else:
								$audio/stone.play()
				return obj
			else:
				var obj_parent=obj.get_parent()
				if obj_parent.name=="player_node":
					if hurt:
						Function.msg_group("2d","_hit")
					return obj
				elif obj_parent.name=="enemy_node":
					return obj
				else:
					return obj
	return null
func check_crack(pos3):
	var block_node = $"../../plane/block"
	var crack_pos = block_node.map_to_world(pos3.x,pos3.y,pos3.z)
	var crack_name=String(pos3.x)+"-"+String(pos3.y)+"-"+String(pos3.z)
	var crack=0
	if block_node.has_node(crack_name):
		if(block_node.get_node(crack_name).index<5):
			block_node.get_node(crack_name).index+=2
			block_node.get_node(crack_name).check_status()
		else:
			block_node.get_node(crack_name).queue_free()
			crack=1
	else:
		var crack_tscn = crack_scene.instance()
		crack_tscn.translation=crack_pos
		crack_tscn.name=crack_name
		block_node.add_child(crack_tscn)
	if Net.status:
		$"../"._forward_1("_play_sound",Net.id,"stone")
	$audio/stone.play()
	return crack
func _play_event():
	$hand.play("event")
	$AnimationTreePlayer.oneshot_node_start("event")
func _play_sound(_name):
	get_node("audio/"+_name).play()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _move_sound():
	var ray=$ray_foot
	ray.force_raycast_update()
	if ray.is_colliding():
		var obj=ray.get_collider()
		if(!obj.is_queued_for_deletion()):
			if obj.has_method("world_to_map"):
				var pos=ray.get_collision_point()
				if obj.name=="road":
					pos+=+Vector3(28.5,-0.9,31.5)
				else:
					pos+=+Vector3(-1.5,3,1.5)
				pos=obj.world_to_map(pos)
				var id = obj.get_cell_item(pos[0], pos[1], pos[2])
				if id!=-1:
					var obj_name = obj.theme.get_item_name(id)
					if obj_name=="ground0":
						$audio/grass.play()
					else:
						$audio/move.play()
					return
			if obj.name=="plane":
				$audio/grass.play()
			else:
				$audio/move.play()
func _delete(name_=0):
	queue_free()