extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var shadow={"pos":Vector3(-13,2,-31),"rot":Vector3(),"chest":Vector3(),"neck":Vector3(),"run":0,"gun":0}
var offset=0.3
var speed=5
var rest
var attack=0
func _ready():

	add_to_group("enemy")
	rest=$Armature/Skeleton.get_bone_pose(6)
	$Armature/hp/Viewport/hp.max_value=100
	$Armature/hp/Viewport/hp.value=hp
	var m0=$Armature/Skeleton/neck/head.get_surface_material(0).duplicate()
	$Armature/Skeleton/neck/head.set_surface_material(0,m0)
	$Armature/Skeleton/body.set_surface_material(0,m0)
	$Armature/Skeleton/left_arm.set_surface_material(0,m0)
	$Armature/Skeleton/right_arm.set_surface_material(0,m0)
	$attack_time.connect("timeout",self,"_on_attack_")
	$dead.connect("timeout",self,"_on_delete")
	$area.connect("body_entered",self,"_on_enter")
	$area.connect("body_exited",self,"_on_exit")
	
	pass
var player=null
var player_list=[]
func _on_enter(obj):
	if obj.get_parent().name=="player_node":
		$audio/default.play()
		if player==null:
			player=obj
		else:
			for data in player_list:
				if data.name==obj.name:return
		player_list.append(obj)
func _on_exit(obj):
	if obj.get_parent().name=="player_node":
		if !player.is_queued_for_deletion():
			for data in player_list:
				if data.name==obj.name:
					player_list.erase(data)
					return
		if player.name==obj.name:
			if player_list.size()>0:
				player=player_list[0]
				player_list.remove(0)
			else:
				player=null
		else:
			for data in player_list:
				if data.name==obj.name:
					player_list.erase(data)
					return
func _process(delta):
	
	if get_slide_count()>=3:
		var offsets=[-0.1,0,+0.1]
		var offset_x=offsets[randi()%2]
		var offset_z=offsets[randi()%2]
		global_translate(Vector3(offset_x,0,offset_z))
	if player!=null:
		if player.is_queued_for_deletion():
			_on_exit(player)
			return
		
		look_at(player.translation,Vector3(0,1,0))
		rotation_degrees.y+=180
		rotation_degrees.x=0
		rotation_degrees.z=0
	var move=0
	var vec3=Vector3(0,-0.5,0)
#	if translation.x<shadow.pos.x-offset:
#		vec3.x+=speed
#		move=1
#	if translation.x>shadow.pos.x+offset:
##		if !get_tree().is_network_server():
##			print("s",translation.x,"s",shadow.pos.x)
#		vec3.x-=speed
#		move=1
#	#w
#	if translation.z<shadow.pos.z-offset:
#		vec3.z+=speed*(shadow.run+1)
#		move=1
#	if translation.z>shadow.pos.z+offset:
#		vec3.z-=speed
#		move=1
#	vec3.y=shadow.pos.y-translation.y
	if player!=null:
		if translation.distance_to(player.translation)<1.3:
			if $ani2.current_animation!="attack":
				$ani2.play("attack")
				$attack_time.start()
		vec3=(player.translation-translation).normalized()
		vec3.y-=0.1
		move=1
	set_bone_rot_arm(8,Vector3(1.5,-0.1,0))
	set_bone_rot_arm(12,Vector3(1.5,0.1,0))
	if move:
		if $ani.current_animation!="walk":
			$ani.play("walk")
		
		if $ani_sound.current_animation!="move_sound":
			$ani_sound.play("move_sound")
	else:
		$ani.stop()
		$ani_sound.stop()
			#$AnimationTreePlayer.transition_node_set_current("state",0)
		#if stop_time>=stop_time_max:
		#	$AnimationPlayer.play("stop")
#	else:
#		get_node("AnimationPlayer").play("stop")
	
	move_and_slide(vec3,Vector3(0,1,0))
	
	#$Armature/Skeleton.rotation_degrees.z=shadow.body
	#$Armature/Skeleton/neck.rotation_degrees=shadow.neck
	#$Camera.rotation_degrees = shadow.neck
	set_bone_rot(6,shadow.chest)
#	if test_move(transform,Vector3(0,-0.4,0)):
#		$AnimationTreePlayer.blend2_node_set_amount("jump",0)
#	else:
#		$AnimationTreePlayer.blend2_node_set_amount("jump",1)
func _on_attack_():
	$audio/attack.play()
	$audio/hueiwu.play()
	if player!=null:
		if translation.distance_to(player.translation)<1.3:
			$"../blood".translation=player.translation
			var id=int(player.name)
			if player.name=="player":
				id=Net.id
			player.get_node("../")._on_hurt(id,"enemy",translation,40)
			$audio/hurt.play()
var hp=100
func _on_hurt(id,tran,num):
	if hp<=0:return
	hp-=num
	$Armature/hp/Viewport/hp.value=hp
	$ani.play("hurt")
	$ani_sound.play("hurt_effect")
	move_and_slide(Vector3(0,10,0),Vector3(0,1,0))
	if hp<=0:
		_on_dead(id)
func _on_dead(id):
	if id==Net.id:
		Function.msg_group("player","_on_add_money",10)
	$ani.play("dead")
	$dead.start()
func set_bone_rot_arm(id,ang):
	var rest_=$Armature/Skeleton.get_bone_rest(id)
	var newpose = rest_.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	$Armature/Skeleton.set_bone_pose(id, newpose)
func set_bone_rot(id, ang):
	var newpose = rest.rotated(Vector3(1.0, 0.0, 0.0), ang.x)
	newpose = newpose.rotated(Vector3(0.0, 1.0, 0.0), ang.y)
	newpose = newpose.rotated(Vector3(0.0, 0.0, 1.0), ang.z)
	$Armature/Skeleton.set_bone_pose(id, newpose)
#func check_ray(hurt=0):
#	var ray=get_node("ray")
#	ray.force_raycast_update()
#	if(ray.is_colliding()):
#		var obj=ray.get_collider()
#		if(!obj.is_queued_for_deletion()):
#			if obj.has_method("world_to_map"):
#				var pos=ray.get_collision_point()
#				if obj.name=="road":
#					pos+=+Vector3(28.5,-0.9,31.5)
#				else:
#					pos*=3.333
#					pos+=+Vector3(5,7.5+3.6,5)
#					pos=obj.world_to_map(pos)
#					var id = obj.get_cell_item(pos[0], pos[1], pos[2])
#					if id!=-1:
#						var obj_name = obj.theme.get_item_name(id)
#						if hurt&&!gun:
#							if obj_name=="ground0":
#								$audio/grass.play()
#							else:
#								$audio/stone.play()
#			else:
#				var obj_parent=obj.get_parent()
#				if obj_parent.name=="player_node":
#					return obj
#				else:
#					return obj_parent
#	return null
func _on_delete():
	queue_free()