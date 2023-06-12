extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player_info=Overall.player_info
var player_name=load("res://scenes/main/2d/name.tscn")
func _ready():

	#加入主角
	var tscn=Overall.player_model[Net.my_info.model].instance()
	tscn.set_name("player")
	tscn.translation=Vector3(-13,2,-31)
	call_deferred("add_child",tscn)
	add_to_group("player_node")

	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	set_process(true)
	pass
master func player(id,data):
	rpc_unreliable("shadow",id,data)
#	get_node(str(id)).rset_unreliable("shadow",data)
	if get_tree().is_network_server():
		if id!=1:
			for key in data:
				if has_node(str(id)):
					get_node(str(id)).shadow[key]=data[key]
#
func _on_action(id,name):
	if Net.id==1:
		_on_action_(id,name)
	else:
		rpc_id(1,"_on_action_",id,name)
master func _on_action_(id,name):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_action_solve(id,name)
			else:
				rpc_id(i,"_on_action_solve",id,name)
remote func _on_action_solve(id,name):
	if has_node(str(id)):
		get_node(str(id))._on_action(name)
#
func _on_event(id):
	if Net.id==1:
		_on_event_(id)
	else:
		rpc_id(1,"_on_event_",id)
master func _on_event_(id):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_event_solve(id)
			else:
				rpc_id(i,"_on_event_solve",id)
remote func _on_event_solve(id):
	if has_node(str(id)):
		get_node(str(id))._on_event()
#
func _on_attack(id):
	if Net.id==1:
		_on_attack_(id)
	else:
		rpc_id(1,"_on_attack_",id)
master func _on_attack_(id):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_attack_solve(id)
			else:
				rpc_id(i,"_on_attack_solve",id)
remote func _on_attack_solve(id):
	if has_node(str(id)):
		get_node(str(id))._on_attack()
#
#
func _on_shot(id):
	if Net.id==1:
		_on_shot_(id)
	else:
		rpc_id(1,"_on_shot_",id)
master func _on_shot_(id):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_shot_solve(id)
			else:
				rpc_id(i,"_on_shot_solve",id)
remote func _on_shot_solve(id):
	if has_node(str(id)):
		get_node(str(id))._on_shot()
#
func _set_pos(id,tr,rot):
	if Net.id==1:
		_on_set_pos(id,tr,rot)
	else:
		rpc_unreliable_id(1,"_on_set_pos",id,tr,rot)
master func _on_set_pos(id,tr,rot):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_set_pos_solve(id,tr,rot)
			else:
				rpc_unreliable_id(i,"_on_set_pos_solve",id,tr,rot)
remote func _on_set_pos_solve(id,tr,rot):
	if has_node(str(id)):
		get_node(str(id)).shadow.pos=tr
		get_node(str(id)).shadow.rot=rot
#

#转发
func _forward(func_name,id):
	if Net.id==1:
		_on_forward_(func_name,id)
	else:
		rpc_id(1,"_on_forward_",func_name,id)
master func _on_forward_(func_name,id):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_forward_solve(func_name,id)
			else:
				rpc_id(i,"_on_forward_solve",func_name,id)
remote func _on_forward_solve(func_name,id):
	if has_node(str(id)):
		get_node(str(id)).call(func_name)
#
func _forward_1(func_name,id,arg1):
	if Net.id==1:
		_on_forward_1(func_name,id,arg1)
	else:
		rpc_id(1,"_on_forward_1",func_name,id,arg1)
master func _on_forward_1(func_name,id,arg1):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_forward_solve_1(func_name,id,arg1)
			else:
				rpc_id(i,"_on_forward_solve_1",func_name,id,arg1)
remote func _on_forward_solve_1(func_name,id,arg1):
	if has_node(str(id)):
		get_node(str(id)).call(func_name,arg1)
#
func _forward_2(func_name,arg1,arg2):
	if Net.id==1:
		_on_forward_2(func_name,Net.id,arg1,arg2)
	else:
		rpc_id(1,"_on_forward_2",func_name,Net.id,arg1,arg2)
master func _on_forward_2(func_name,id,arg1,arg2):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_forward_solve_2(func_name,id,arg1,arg2)
			else:
				rpc_id(i,"_on_forward_solve_2",func_name,id,arg1,arg2)
remote func _on_forward_solve_2(func_name,id,arg1,arg2):
	if has_node(str(id)):
		get_node(str(id)).call(func_name,arg1,arg2)
##
func _on_hurt(id,id_,tran,num):
	if Net.id==1:
		_on_hurt_(id,id_,tran,num)
	else:
		rpc_id(1,"_on_hurt_",id,id_,tran,num)
master func _on_hurt_(id,id_,tran,num):
	#收到攻击  攻击者
	for i in player_info:
		if i==1&&Net.id==1:
			_on_hurt_solve(id,id_,tran,num)
		else:
			rpc_id(i,"_on_hurt_solve",id,id_,tran,num)
remote func _on_hurt_solve(id,id_,tran,num):
	if id==Net.id:
		get_node("player")._on_hurt(id,id_,tran,num)
	else:
		if has_node(str(id)):
			get_node(str(id))._on_hurt(id,id_,tran,num)
#
func _on_dead(_id,id_):
	if Net.id==1:
		_on_dead_(_id,id_)
	else:
		rpc_id(1,"_on_dead_",_id,id_)
master func _on_dead_(_id,id_):
	for i in player_info:
		if i==1&&Net.id==1:
			_on_dead_solve(_id,id_)
		else:
			rpc_id(i,"_on_dead_solve",_id,id_)
remote func _on_dead_solve(_id,id_):
	if id_ in Net.player_info:
		Net.player_info[id_].kill+=1
		Net.player_info[id_].money+=10
	if _id in Net.player_info:
		Net.player_info[_id].dead+=1
	$player._on_dead_num(_id,id_)
#
func _on_new_life(id):
	if Net.id==1:
		_on_new_life_(id)
	else:
		rpc_id(1,"_on_new_life_",id)
master func _on_new_life_(id):
	for i in player_info:
		if i==1&&Net.id==1:
			_on_new_life_solve(id)
		else:
			rpc_id(i,"_on_new_life_solve",id)
remote func _on_new_life_solve(id):
	if id==Net.id:
		get_node("player")._on_new_life()
	else:
		if has_node(str(id)):
			get_node(str(id))._on_new_life()
#
func shadow(id,data):
	if Net.id==1:
		shadow_(id,data)
	else:
		rpc_unreliable_id(1,"shadow_",id,data)
remote func shadow_(id,data):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				shadow_solve(id,data)
			else:
				rpc_unreliable_id(i,"shadow_solve",id,data)
remote func shadow_solve(id,data):
	if has_node(str(id)):
		for key in data:
			get_node(str(id)).shadow[key]=data[key]
#######
func _on_msg_model():
	if Net.status:
		_on_model(Net.id,Net.my_info.model)
	if Net.id in Net.player_info:
		Net.player_info[Net.id].model=Net.my_info.model
	var hp=$player.hp
	var tran=$player.translation
	$player.set_name("player_be")
	$player_be._delete()
	var tscn=Overall.player_model[Net.my_info.model].instance()
	tscn.set_name("player")
	tscn.hp=hp
	tscn.translation=tran
	add_child(tscn)

func _on_model(id,model):
	if Net.id==1:
		_on_model_(id,model)
	else:
		rpc_id(1,"_on_model_",id,model)
master func _on_model_(id,model):
	for i in player_info:
		if i !=id:
			if i==1&&Net.id==1:
				_on_model_solve(id,model)
			else:
				rpc_id(i,"_on_model_solve",id,model)
remote func _on_model_solve(id,model):
	if id in Net.player_info:
		Net.player_info[id].model=model
		if has_node(str(id)):
			var keys_a=["hp","tran","bullet","bullet_max","bullet_z"]
			var keys_j={}
			for data in keys_a:
				if data in get_node(str(id)):
					keys_j[data]=get_node(str(id))[data]
			get_node(str(id)).set_name(str(id)+"be")
			get_node(str(id)+"be")._delete(id)
			
			var player_other=Overall.player_model_other[model]
			var tscn=player_other.instance()
			tscn.set_name(str(id))
			for key in keys_j:
				tscn[key]=keys_j[key]
			add_child(tscn)
#######
var created_model=[]
func check_player():
	for id in Net.player_info:
		if id!=get_tree().get_network_unique_id():
			if !has_node(str(id)):
				
				if id in created_model:
					return
				else:
					created_model.append(id)
				var player_other=Overall.player_model_other[Net.player_info[id].model]
				var tscn=player_other.instance()
				
				tscn.set_name(str(id))
				var subs=[-40,0]
				var sub=subs[randi()%2]
				tscn.translation=Vector3(randi()%21-sub,randi()%100+1,-31)
				
				call_deferred("add_child",tscn)

	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _process(delta):
	for i in Net.player_info:
		if typeof(i)==TYPE_INT:
			if Net.id!=i:
				if has_node(str(i)):
					var other=get_node(str(i))
					var tran=other.translation
					var _name_
					if has_node("../2d/"+str(i)):
						_name_=get_node("../2d/"+str(i))
					if !has_node("player"):
						_name_.hide()
						return
					var camera=get_node("player").camera
					if !camera.is_position_behind(tran): 
						tran.y+=2
						var vec=camera.unproject_position(tran) 
						if _name_:
							_name_.show()
							_name_.position=vec
					else:
						if _name_:
							_name_.hide()