extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var hp=100
var kill=0
var dead=0
var speed=5
const GRAVITY=5
var jump_speed=10
var air_time=0
var offset=0.3
var stop_time=0
var stop_time_max=0.2

var camera_h=0

var materials=Overall.materials
onready var camera=$Camera
onready var chest_bone=Overall.chests[Net.player_info[int(name)].model]
onready var stop_bones=Overall.stop_bones[Net.player_info[int(name)].model]
onready var handheld=Overall.handhelds[Net.player_info[int(name)].model]
onready var neck=$Armature/Skeleton/neck
var gun_tscn=Overall.tscn.gun
var rest=null
var gun=0
var clip_first=1
var this={}
var player_name=load("res://scenes/main/2d/name.tscn")
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
var car=0
func _set_pos(tr,rot):
	translation=tr
	rotation_degrees = rot
	shadow.pos=tr
	shadow.rot=rot
	shadow.run=0
func _set_pos_other(tr):
	translation=tr
	shadow.pos=tr
	shadow.run=0
func _on_build(pos3,id):
	$AnimationTreePlayer.oneshot_node_start("event")
	$"../../plane"._on_build(pos3,id,name)
func _play_sound(_name):
	get_node("audio/"+_name).play()
func _change_hand(id):
	block_id=id
	if has_node("Armature/Skeleton/hand/block/block"):
		$Armature/Skeleton/hand/block/block.free()
	call_deferred("change_block")
func change_block():
	if block_id in blocks_scene:
		var block_scene=blocks_scene[block_id].instance()
		block_scene.name="block"
		$Armature/Skeleton/hand/block.add_child(block_scene)
func _msg(text):
	$msg._show(text)
func _enter_tree():
	var time = Timer.new()
	time.one_shot=true
	time.wait_time=1.8
	time.set_name("clip_time")
	add_child(time)
func spot(be):
	$Armature/Skeleton/head/spot.visible=be
func _on_damage(block_pos,block_id):
	$"../../plane"._on_damage(block_pos,block_id,name)
func _ready():
	$Camera/ray.add_exception(self)
	$Camera_h/Camera_h/ray.add_exception(self)
	spot(0)
	_change_gun(0)
	$Armature/Skeleton/head/spot.scale=Vector3(handheld/10,handheld/10,handheld/10)
	$clip_time.connect("timeout",self,"_clip_sound")
	rest=$Armature/Skeleton.get_bone_pose(chest_bone)
	if Net.player_info[int(name)].model==0||Net.player_info[int(name)].model==3:
		var m0=$Armature/Skeleton/neck/head.get_surface_material(0).duplicate()
		$Armature/Skeleton/neck/head.set_surface_material(0,m0)
		$Armature/Skeleton/body.set_surface_material(0,m0)
		$Armature/Skeleton/left_arm.set_surface_material(0,m0)
		$Armature/Skeleton/right_arm.set_surface_material(0,m0)
	elif Net.player_info[int(name)].model==1:
		this["m0"]=$Armature/Skeleton/neck/head.get_surface_material(0).duplicate()
		this["m1"]=$Armature/Skeleton/neck/head.get_surface_material(1).duplicate()
		this["m2"]=$Armature/Skeleton/neck/head.get_surface_material(2).duplicate()
		this["m3"]=$Armature/Skeleton/neck/head.get_surface_material(3).duplicate()
		for i in materials[Net.player_info[int(name)].model][1]:
			$Armature/Skeleton/body.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.player_info[int(name)].model][0]:
			$Armature/Skeleton/neck/head.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.player_info[int(name)].model][2]:
			$Armature/Skeleton/left_arm.set_surface_material(i,this["m"+str(i)])
		for i in materials[Net.player_info[int(name)].model][3]:
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
		for i in materials[Net.player_info[int(name)].model][1]:
			$Armature/Skeleton/body.set_surface_material(i,this["h"+str(i)])
		for i in materials[Net.player_info[int(name)].model][0]:
			$Armature/Skeleton/neck/head.set_surface_material(i,this["b"+str(i)])
		for i in materials[Net.player_info[int(name)].model][2]:
			$Armature/Skeleton/left_arm.set_surface_material(i,this["b11"])
		for i in materials[Net.player_info[int(name)].model][3]:
			$Armature/Skeleton/right_arm.set_surface_material(i,this["b11"])
	
	$Armature/hp/Viewport/hp.max_value=100
	$Armature/hp/Viewport/hp.value=hp
	add_to_group(name)
	_change_gun(0)
	
	if !has_node("../../2d"+name):
		var tscn=player_name.instance()
		tscn.set_name(name)
		tscn.get_node("text").text=Overall.player_info[int(name)].name
		tscn.hide()
		get_node("../../2d").add_child(tscn)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$time.connect("timeout",self,"_timeout")
	$attack_time.connect("timeout",self,"_on_attack_")
	$time.start()
#	$AnimationPlayer.connect("animation_finished",self,"_on_finished")
var shadow={"pos":Vector3(-13,2,-31),"rot":Vector3(),"body":0,"chest":Vector3(),"neck":Vector3(),"camera":Vector3(),"camera_h":Vector3(),"run":0,"gun":0}
#func _on_finished(name):
#	$AnimationTreePlayer.transition_node_set_current("state",0)
func _on_attack():
	if !$AnimationTreePlayer.oneshot_node_is_active("attack"):
		$AnimationTreePlayer.oneshot_node_start("attack") 
		$attack_time.start()
func _on_attack_():
	$audio/hueiwu.play()
	var obj=check_ray(1)
	var vec3=camera.get_node("ray").get_collision_point()
	$"../gun".translation=vec3
	$"../blood".translation=vec3
	if obj:
		if obj.get_parent().name=="player_node":
			$"../blood".restart()
		elif obj.get_parent().name=="enemy_node":
			$"../blood".restart()
		else:
			$"../gun".restart()
func _on_shot():
	if $clip_time.time_left!=0:return
	
	$audio/shot0.play()
	
	$Armature/Skeleton/hand/gun._on_shot(camera.project_position(get_viewport().get_mouse_position()))
	var obj=check_ray(1,gun)
	var vec3=camera.get_node("ray").get_collision_point()
	$"../gun".translation=vec3
	$"../blood".translation=vec3
	if obj:
		if obj.get_parent().name=="player_node":
			$"../blood".restart()
		else:
			$"../gun".restart()
func _on_change_camera(node_name):
	camera=get_node(node_name)
	if node_name=="Camera_h/Camera_h":
		camera_h=1
	else:
		camera_h=0
func _on_change_clip():
	if $clip_time.time_left!=0:return
	$clip_time.wait_time=1.8
	$clip_time.start()
	_clip_sound()
	$AnimationTreePlayer.oneshot_node_start("clip")
	$Armature/Skeleton/hand/gun._on_change_clip()
func _clip_sound():
	var id =0
	if !clip_first:
		id=1
	get_node("audio/clip"+str(id)).play()
	clip_first=!clip_first

var chest=Vector3()
func _change_gun(mode):
	gun=mode
	if gun:
		if !has_node("Armature/Skeleton/hand/gun"):
			var gun_scene=gun_tscn[0].instance()
			gun_scene.name="gun"
			gun_scene.scale=Vector3(handheld,handheld,handheld)
			$Armature/Skeleton/hand.add_child(gun_scene)
			for data in stop_bones:
				$AnimationTreePlayer.blend2_node_set_filter_path ("stop","Armature/Skeleton:"+data,true)
			for i in range(1,5):
				$AnimationTreePlayer.mix_node_set_amount("hand"+str(i),0)
			$AnimationTreePlayer.mix_node_set_amount("gun",1)
			neck.rotation_degrees=Vector3()
	else:
		if has_node("Armature/Skeleton/hand/gun"):
			$Armature/Skeleton/hand/gun.queue_free()
			var offset=1
			if Net.my_info.model==1:
				offset=0.8
			for data in stop_bones:
				$AnimationTreePlayer.blend2_node_set_filter_path ("stop","Armature/Skeleton:"+data,false)
			for i in range(1,5):
				$AnimationTreePlayer.mix_node_set_amount("hand"+str(i),offset)
			$AnimationTreePlayer.mix_node_set_amount("gun",0)
			chest=Vector3()
			set_bone_rot(chest_bone,chest)

func _on_hurt(_id,id_,tran,num):
	if hp<=0:return
	Net.player_info[_id].hp-=num
	hp-=num
	$Armature/hp/Viewport/hp.value=hp
	if hp<=0:
		_on_dead(_id,id_)
	else:
		$AnimationTreePlayer.oneshot_node_is_active("hurt")
		$AnimationPlayer.play("hurt_effect")
	$audio/hurt.play()
	move_and_slide(Vector3(0,20,0),Vector3(0,1,0))
func _on_dead(_id,id_):
	Function.msg_group("2d","_money",Net.my_info.money)
	var id_name
	if typeof(id_)!=TYPE_INT:
		id_name=id_
	else:
		id_name=Net.player_info[id_].name
	var text=id_name+" "+tr("kill")+" "+Net.player_info[_id].name
	Function.msg_group("msg","_add_text",text,"yellow")
	$AnimationPlayer.play("dead")
func _on_new_life():
	hp=100
	$Armature/hp/Viewport/hp.value=hp
	$AnimationPlayer.play("new_life")
	translation=Vector3(-18,2,-31)
func _on_action(name):
	if $AnimationPlayer.current_animation==name:
		if $AnimationPlayer.is_playing():
			return
	$AnimationPlayer.play(name)
func _on_event():
	$AnimationTreePlayer.oneshot_node_start("event")
func _on_get_on_car():
	car=1
func _on_get_off_car():
	translation.y+=2
	car=0
func _timeout():
	if !car:
		translation=shadow.pos
#_physics_process
func _process(delta):
	
	var move=0
	var vec3=Vector3()
	if translation.x<shadow.pos.x-offset:
		vec3.x+=speed
		move=1
	if translation.x>shadow.pos.x+offset:
#		if !get_tree().is_network_server():
#			print("s",translation.x,"s",shadow.pos.x)
		vec3.x-=speed
		move=1
	#w
	if translation.z<shadow.pos.z-offset:
		vec3.z+=speed*(shadow.run+1)
		move=1
	if translation.z>shadow.pos.z+offset:
		vec3.z-=speed
		move=1
	vec3.y=shadow.pos.y-translation.y
	
	if move:
		if shadow.run:
			$AnimationTreePlayer.blend2_node_set_amount("walk_mode",1)
		else:
			$AnimationTreePlayer.blend2_node_set_amount("walk_mode",0)
		stop_time=0
		$AnimationTreePlayer.timescale_node_set_scale("walk_speed",1)
		$AnimationTreePlayer.blend2_node_set_amount("stop",0)
		if !$AnimationPlayer.is_playing():
			if shadow.run:
				$AnimationPlayer.play("move_sound",-1,2)
			else:
				$AnimationPlayer.play("move_sound")
		
	else:
		if stop_time>=stop_time_max:
			stop_time=0
			$AnimationTreePlayer.timescale_node_set_scale("walk_speed",0)
			#$AnimationTreePlayer.transition_node_set_current("state",0)
		else:
			stop_time+=delta
		
		
		stop_time+=delta
		#if stop_time>=stop_time_max:
		#	$AnimationPlayer.play("stop")
#	else:
#		get_node("AnimationPlayer").play("stop")
	if !car:
		move_and_slide(vec3,Vector3(0,1,0))
	rotation_degrees=shadow.rot
	if int(name) in Net.player_info:
		if Net.player_info[int(name)].model==2:
			$Armature/Skeleton.rotation_degrees.y=-shadow.body
		else:
			$Armature/Skeleton.rotation_degrees.z=shadow.body
	$Armature/Skeleton/neck.rotation_degrees=shadow.neck
	$Camera.rotation_degrees = shadow.camera
	$Camera_h.rotation_degrees = shadow.camera_h
	set_bone_rot(chest_bone,shadow.chest)
	if gun!=shadow.gun:
		for data in stop_bones:
			$AnimationTreePlayer.blend2_node_set_filter_path ("stop","Armature/Skeleton:"+data,shadow.gun)
		for i in range(1,5):
			$AnimationTreePlayer.mix_node_set_amount("hand"+str(i),!shadow.gun)
			$AnimationTreePlayer.mix_node_set_amount("gun",shadow.gun)
	if test_move(transform,Vector3(0,-0.4,0)):
		$AnimationTreePlayer.blend2_node_set_amount("jump",0)
		if shadow.gun:
			$AnimationTreePlayer.mix_node_set_amount("gun",1)
	else:
		if shadow.gun:
			$AnimationTreePlayer.mix_node_set_amount("gun",0)
		$AnimationTreePlayer.blend2_node_set_amount("jump",1)
#		var camera_rot = camera.rotation_degrees
#		camera_rot.x = clamp(camera_rot.x, -70, 70)
#		camera.rotation_degrees = camera_rot
#		print(camera.rotation_degrees)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func set_bone_rot(id, ang):
	if rest==null:return
	var newpose = rest.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	$Armature/Skeleton.set_bone_pose(id, newpose)
func check_ray(hurt=0,gun=0):
	var ray=camera.get_node("ray")
	if gun:
		ray.cast_to.z=3000
	else:
		ray.cast_to.z=1
	if camera_h==1:
		ray.cast_to.z+=1.4
	ray.force_raycast_update()
	if(ray.is_colliding()):
		var obj=ray.get_collider()
		if(!obj.is_queued_for_deletion()):
			if obj.has_method("world_to_map"):
				var pos=ray.get_collision_point()
				if obj.name=="road":
					pos+=+Vector3(28.5,-0.9,31.5)
				else:
					pos*=3.333
					pos+=+Vector3(5,7.5+3.6,5)
					pos=obj.world_to_map(pos)
					var id = obj.get_cell_item(pos[0], pos[1], pos[2])
					if id!=-1:
						var obj_name = obj.theme.get_item_name(id)
						if hurt&&!gun:
							if obj_name=="ground0":
								$audio/grass.play()
							else:
								$audio/stone.play()
			else:
				var obj_parent=obj.get_parent()
				if obj_parent.name=="player_node":
					return obj
				elif obj_parent.name=="enemy_node":
					return obj
				else:
					return obj_parent
	return null
func _move_sound():
	var ray=$ray_foot
	ray.force_raycast_update()
	if(ray.is_colliding()):
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
	if name_:
		name_="../../2d/"+str(name_)
	else:
		name_="../../2d/"+name
	if has_node(name):
		get_node(name).queue_free()
	queue_free()
