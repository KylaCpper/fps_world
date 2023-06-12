extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func _ready():
	add_to_group("esc")
	$main/set.connect("pressed",self,"_set")
	$main/server.connect("pressed",self,"_server")
	$main/exit.connect("pressed",self,"_exit")
	$main/cannel.connect("pressed",self,"_cannel")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func display():
	Overall._gui("esc",!Overall.esc)
	if Overall.esc:
		show()
	else:
		hide()
	
func _set():
	$set_page.show()
	pass
func _server():
	var port=21240
	var num=16
	if Net.status:
		Function.msg_group("msg","_add_text","请不要做愚蠢的事")
	else:
		Net.create_server(port,num)
		Function.msg_group("msg","_add_text","create_server_success")
		Function.msg_group("msg","_add_text","ip: "+IP.get_local_addresses()[0])
		Function.msg_group("msg","_add_text","port: "+str(port))
	Overall._gui("esc",0)
	hide()
	pass
func _exit():
	hide()
	if Net.status!=0:
		Net.close_connect()
	Function.msg_group("world","_renew")
	Global.GoTo_Scene("res://scenes/start/main.tscn")
	
	pass
func _cannel():
	Overall._gui("esc",0)
	hide()
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
