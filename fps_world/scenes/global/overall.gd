extends Node
var my_info={"name":"kylaCpp","kill":0,"dead":0,"hp":100,"model":0,"money":20}
var player_model_other=[
	load("res://scenes/model/player/player0/player_other.tscn"),
	load("res://scenes/model/player/player1/player_other.tscn"),
	load("res://scenes/model/player/player2/player_other.tscn"),
	load("res://scenes/model/player/player3/player_other.tscn"),
]
var player_model=[
	load("res://scenes/model/player/player0/player.tscn"),
	load("res://scenes/model/player/player1/player.tscn"),
	load("res://scenes/model/player/player2/player.tscn"),
	load("res://scenes/model/player/player3/player.tscn"),
]
var player_info={}
var set_data={
	"sound":70,
	"music":70,
	"model":0,
	"language":1,
	
}
var materials=[
	[[0],[0],[0],[0]],
	[[0,1,2,3],[0,1,2],[0],[0]],
	[[0,3,6,11,17],[7,26,27],[1],[1]],
	[[0],[0],[0],[0]],
]
var grids={
	
}
var time=8.0
var chests=[
	2,4,68,6
	
]
var handhelds=[
	100,200,10,10
]
var stop_bones=[
	[],["L_arm","R_arm","R_elbow","R_hand"],["Right arm","Right elbow","Right wrist","RingFinger1_R","RingFinger2_R","Left arm","Left elbow"],
	["Right_Arm","Right_Hand","Left_Arm","Left_Hand"]
]
var tscn={
	"gun":[
		load("res://scenes/model/gun/gun0.tscn"),
	]
	
}
var gui=0
var esc=0
var msg=0
var dead=0
var shop=0
func _ready():
	var data=Function.GetSaveData("set.save")
	if data:
		if "model" in data:
			set_data=data
		else:
			Function.SetSaveData("set.save",set_data)
	else:
		Function.SetSaveData("set.save",set_data)
	my_info.model=set_data.model
	my_info.model=0
func _gui(variable,be):
	self[variable]=be
	if esc||msg||dead||shop:
		gui=1
	else:
		gui=0
	if gui:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	