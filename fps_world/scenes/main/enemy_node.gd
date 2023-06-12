extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player_info=Net.player_info
var enemy=load("res://scenes/model/enemy/enemy0.tscn")
func _ready():
	add_to_group("enemy_node")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	pass
##
func _on_hurt(n_name,id_,tran,num):
	if Net.id==1:
		_on_hurt_(n_name,id_,tran,num)
	else:
		rpc_id(1,"_on_hurt_",n_name,id_,tran,num)
master func _on_hurt_(n_name,id_,tran,num):
	#收到攻击  攻击者
	for i in player_info:
		if i==1&&Net.id==1:
			_on_hurt_solve(n_name,id_,tran,num)
		else:
			rpc_id(i,"_on_hurt_solve",n_name,id_,tran,num)
remote func _on_hurt_solve(n_name,id_,tran,num):
	if has_node(str(n_name)):
		get_node(str(n_name))._on_hurt(id_,tran,num)
#
var tran_rans=[
	Vector3(5,1,6),Vector3(3,1,0),Vector3(-0.5,1,-17.2),
	Vector3(2,1,-23),Vector3(-22,1,-23),Vector3(-13,1,-21),
	Vector3(-22,1,-11),Vector3(-22,1,-1),Vector3(-16,1,8),
	Vector3(2,1,-23),Vector3(-8,1,5),Vector3(20,1,4),
	Vector3(30,1,-22),Vector3(20,1,-13),Vector3(4.5,1,25),
	Vector3(26,1,35),Vector3(-21,1,20),Vector3(8,1,-1)
]
var indexs_be=[-1,-1,-1,-1,-1]
func _randi(indexs,i):
	indexs[i]=randi()%18
	for data in indexs_be:
		if data==indexs[i]:
			_randi(indexs,i)
	indexs_be[i]=indexs[i]
func _on_init_enemy():
	if Net.status:
		if Net.id==1:
			var indexs={}
			for i in range(5):
				_randi(indexs,i)
			for i in player_info:
				if i == 1:
					_create_enemy(indexs)
				else:
					rpc_id(i,"_create_enemy",indexs)
	else:
		var indexs={}
		for i in range(5):
			_randi(indexs,i)
		_create_enemy(indexs)
remote func _create_enemy(indexs):
	print("_on_init_enemy")
	for i in indexs:
		var tscn=enemy.instance()
		tscn.translation=tran_rans[indexs[i]]
		add_child(tscn)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
