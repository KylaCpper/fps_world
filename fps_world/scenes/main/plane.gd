extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar
onready var player_info=Net.player_info
func _ready():
	add_to_group("plane")
	if Net.status:
		if Net.id!=1:
			Net.rpc_id(1,"send_data_plane",Net.id)
	# Called when the node is added to the scene for the first time.
	# Initialization here
func _init_block():
	for i in Overall.grids:
		for ii in Overall.grids[i]:
			for iii in Overall.grids[i][ii]:
				call_deferred("_on_build",Vector3(i,ii,iii),Overall.grids[i][ii][iii],0)
	pass
#增加方块
func _on_build(pos3_,id,groupid):
	var pos3=$block.world_to_map(pos3_)
	if $block.get_cell_item(pos3[0],pos3[1],pos3[2])!=-1:
		return
	#grids 增加
	if pos3[0] in Overall.grids:
		if pos3[1] in Overall.grids[pos3[0]]:
			if pos3[2] in Overall.grids[pos3[0]][pos3[1]]:
				Overall.grids[pos3[0]][pos3[1]][pos3[2]]=id
			else:
				Overall.grids[pos3[0]][pos3[1]][pos3[2]]=id
		else:
			Overall.grids[pos3[0]][pos3[1]]={}
			Overall.grids[pos3[0]][pos3[1]][pos3[2]]=id
	else:
		Overall.grids[pos3[0]]={}
		Overall.grids[pos3[0]][pos3[1]]={}
		Overall.grids[pos3[0]][pos3[1]][pos3[2]]=id
	if groupid:
		Function.msg_group(groupid,"_play_sound","stone")
	$block.set_cell_item(pos3[0],pos3[1],pos3[2],id)
#######
#去除方块
func _on_damage(pos3_,id,groupid):
	var pos3=$block.world_to_map(pos3_)
	if $block.get_cell_item(pos3[0],pos3[1],pos3[2])==-1:
		return
	#grids 去除
	if pos3[0] in Overall.grids:
		if pos3[1] in Overall.grids[pos3[0]]:
			if pos3[2] in Overall.grids[pos3[0]][pos3[1]]:
				Overall.grids[pos3[0]][pos3[1]].erase([pos3[2]])
	if groupid:
		Function.msg_group(groupid,"_play_sound","stone")
	$block.set_cell_item(pos3[0],pos3[1],pos3[2],-1)
######
func create_car(car,tr):
	if Net.status:
		rpc("create_car",car,tr)
	var tscn=load("res://scenes/model/car/car"+str(car)+".tscn").instance()
	tscn.translation=tr
	add_child(tscn)
func _on_event(id,obj):
	if Net.status:
		if Net.id==1:
			_on_event_receive(id,obj.get_path())
		else:
			rpc_id(1,"_on_event_receive",id,obj.get_path())
	else:
		_on_event_solve(id,obj.get_path())
master func _on_event_receive(id,path):
	for i in player_info:
		if i==1&&Net.id==1:
			_on_event_solve(id,path)
		else:
			rpc_id(i,"_on_event_solve",id,path)
remote func _on_event_solve(id,path):
	if has_node(path):
		get_node(path)._on_event(id)
############
func _on_hurt(id,obj=null):
	if !obj:return
	if Net.status:
		if Net.id==1:
			_on_hurt_(id,obj.get_path())
		else:
			rpc_id(1,"_on_hurt_",id,obj.get_path())
	else:
		_on_hurt_solve(id,obj.get_path())
func _on_hurt_(id,path):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_hurt_solve(id,path)
			else:
				rpc_id(i,"_on_hurt_solve",id,path)
		else:
			_on_hurt_solve(id,path)
func _on_hurt_solve(id,path):
	if has_node(path):
		get_node(path)._on_hurt(id)
		
		
		
		
####
func _forward(func_name,id,path):
	if Net.id==1:
		_on_forward(func_name,id,path)
	else:
		rpc_id(1,"_on_forward",func_name,id,path)
master func _on_forward(func_name,id,path):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_forward_solve(func_name,path)
			else:
				rpc_id(i,"_on_forward_solve",func_name,path)
remote func _on_forward_solve(func_name,path):
	if has_node(path):
		get_node(path).call(func_name)
####
####
func _forward_1(func_name,id,path,arg1):
	if Net.id==1:
		_on_forward_1(func_name,id,path,arg1)
	else:
		rpc_id(1,"_on_forward_1",func_name,id,path,arg1)
master func _on_forward_1(func_name,id,path,arg1):
	for i in player_info:
		if i != id:
			if i==1&&Net.id==1:
				_on_forward_solve_1(func_name,path,arg1)
			else:
				rpc_id(i,"_on_forward_solve_1",func_name,path,arg1)
remote func _on_forward_solve_1(func_name,path,arg1):
	if has_node(path):
		get_node(path).call(func_name,arg1)
####



	