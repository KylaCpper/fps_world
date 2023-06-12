extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	add_to_group("msg")
	if Net.status:
		if get_tree().is_network_server():
			_add_text(tr("create_server_success"))
			_add_text("ip: "+IP.get_local_addresses()[0])
			_add_text("port: "+Net.port)
		else:
			_add_text(tr("connect_success"))
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
remote func _add_text(text,color=null):
	if color:
		$msg.append_bbcode("\n[color="+color+"]"+text+"[/color]")
	else:
		$msg.add_text("\n"+text)
	$msg.scroll_to_line($msg.get_line_count()-1)
	if !$label.text==">":
		$ani.play("msg")
remote func _accept_add_text(id,text):
	
	if Net.id==1&&id==1:
		_add_text(Overall.my_info.name+": "+text)
		Function.msg_group("player","_msg",text)
		return
	
	if id in Overall.player_info:
		_add_text(Overall.player_info[id].name+": "+text)
		if Net.id==id:
			Function.msg_group("player","_msg",text)
		else:
			Function.msg_group(str(id),"_msg",text)
	
func _add_msg(text):
	if text:
		if text[0]=="/":
			text=text.right(1)
			if text:
				_code(text)
		else:
				_add_text(text)

func display():
	Overall._gui("msg",!Overall.msg)
	if Overall.msg:
		show()
		$edit.grab_focus()
		$label.text=">"
		$edit.caret_position =1
		$ani.play("show")
		
	else:
		$edit.release_focus()
		if Net.status:
			#rpc("_accept_msg",$edit.text)
			_send_msg($edit.text)
		else:
			_add_msg($edit.text)
		$edit.text=""
		$label.text=""
		$ani.play("msg")
func _code(text):
	var arr = text.split(" ", true);
	var code = arr[0]
	if code=="my_info":
		_add_text("name: "+Overall.my_info.name,"green")
	elif code=="info":
		for key in Overall.player_info:
			_add_text("name: "+Overall.player_info[key].name,"green")
	elif code=="ip":
		if Net.status:
			_add_text("ip: "+Net.ip,"green")
			_add_text("port: "+str(Net.port),"green")
		else:
			_add_text("ip: "+IP.get_local_addresses()[0],"green")
	elif code=="buy_bullet":
		if Net.my_info.money:
			if arr.size()<2:
				_add_text(tr("buy_bullet")+str(Net.my_info.money),"green")
				$"../../player_node/player".bullet_z+=Net.my_info.money
				Net.my_info.money=0
			else:
				var num = int(arr[1])
				if num>0:
					if Net.my_info.money-num>0:
						_add_text(tr("buy_bullet")+str(num),"green")
						Net.my_info.money-=num
						$"../../player_node/player".bullet_z+=num
					else:
						_add_text(tr("buy_bullet")+str(Net.my_info.money),"green")
						$"../../player_node/player".bullet_z+=Net.my_info.money
						Net.my_info.money=0
			Function.msg_group("2d","_bullet",$"../../player_node/player".bullet,$"../../player_node/player".bullet_z)
			Function.msg_group("2d","_money",Net.my_info.money)
	elif code=="set_time":
		if arr.size()>1:
			var time=float(arr[1])
			Function.msg_group("world","_change_time",time)
			_add_text(tr("set_time"),"green")
	elif code=="init_enemy":
		if Net.status:
			if Net.id==1:
				Function.msg_group("enemy_node","_on_init_enemy")
	elif code=="save_game":
		Function.SetSaveData("friends_world.save",{"grids":Overall.grids},"ky")
	elif code=="create_car":
		if arr.size()>1:
			var car=float(arr[1])
			Function.msg_group("player","create_car",car)
	else:
		_add_text("err_code","red")
master func _accept_msg(id,text):
	rpc("_accept_add_text",id,text)
	_accept_add_text(id,text)
func _send_msg(text):
	if text:
		if text[0]=="/":
			_add_msg(text)
		else:
			if Net.id==1:
				_accept_msg(Net.id,text)
			else:
				rpc_id(1,"_accept_msg",Net.id,text)
			
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
