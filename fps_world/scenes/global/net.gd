extends Node
# class member variables go here, for example:
# var a = 2
var peer = NetworkedMultiplayerENet.new()
var status=0
var server_err=0
var port=0
var ip=""
var id=1
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#peer.create_client("127.0.0.1",21240)
#	get_tree().set_meta("network_peer", peer)
#	print(get_tree().get_network_unique_id())
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	pass
	
	
func close_connect():
	peer.close_connection()
	for id in player_info.keys():
		player_info.erase(id)
	status=0
func create_server(port,num):
	self.port=port
	ip=IP.get_local_addresses()[0]
	peer.create_server(int(port), int(num))
	get_tree().set_network_peer(peer)
	while (1):
		if get_tree().is_network_server():
			status=1
			player_info[1]=my_info
			return
func connect_server(ip,port):
	self.port=port
	self.ip=ip
	#ip=IP.resolve_hostname(ip) 
	#print(ip)
	peer.create_client(ip,int(port))
	get_tree().set_network_peer(peer)
# Player info, associate ID to data
onready var player_info = Overall.player_info
# Info we send to other players
onready var my_info = Overall.my_info

func _player_connected(id):
	print("client in",id)
	#客户端进来
	pass

func _player_disconnected(id):
	print("client disconnect",id)
	#客户端断开
	disconnect_player(id)
	

func _connected_ok():
	print("connect success")
	status=1
	#连接服务器成功
	id=get_tree().get_network_unique_id()
	Global.GoTo_Scene("res://scenes/main/main.tscn")
	#rpc("register_player", get_tree().get_network_unique_id(), my_info)
	
func _server_disconnected():
	print("server disconnect")
	close_connect()
	server_err=1
	Global.GoTo_Scene("res://scenes/start/main.tscn")
	
	#服务器断开
	pass 

func _connected_fail():
	print("connect err")
	Function.msg_group("msg","_on_show","connect_err")
	Function.msg_group("loading","hide")
	status=0
	close_connect()
	#连接失败
	pass 
##发送数据给新进来人
remote func send_data_plane(id):
	rpc_id(id, "notice_data_plane",Overall.grids)
remote func notice_data_plane(data):
	Overall.grids=data
	Function.msg_group("plane","_init_block")

remote func register_player(id, info):
	# Store the info
	player_info[id] = info
	player_info[Net.id] = my_info
	Function.msg_group("player_node","check_player")
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
		# Send my info to new player
		if id!=1:
			rpc_id(id, "register_player", 1, my_info)
	# Send the info of existing players
		for peer_id in player_info:
			for peer_id_ in player_info: 
				if peer_id!=1:
					rpc_id(peer_id, "register_player", peer_id_, player_info[peer_id_])
remote func disconnect_player(id):
	if !id in player_info:return
	player_info.erase(id)
	Function.msg_group(str(id),"_delete")
	if get_tree().is_network_server():
		#发送掉线的客户端id所有客户端
		for peer_id in player_info:
			rpc_id(id, "disconnect_player", peer_id)