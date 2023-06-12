extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$start.connect("pressed",self,"_start")
	$multiplayer.connect("pressed",self,"_multiplayer")
	$fast_connect.connect("pressed",self,"_fast")
	$set.connect("pressed",self,"_set")
	$language.connect("pressed",self,"_language")
	$exit.connect("pressed",self,"_exit")
#	Steam.steamInit()
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func _start():
	Net.status=0
	Global.GoTo_Scene("res://scenes/main/main.tscn")
func _multiplayer():
	$multiplayer_page.show()
func _fast():
	$fast_page.show()
func _set():
	$set_page.show()
func _language():
	$language_page.show()
func _exit():
	get_tree().quit()
	pass

