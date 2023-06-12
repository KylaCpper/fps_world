extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	add_to_group("msg")
	if Net.server_err:
		_on_show("server_disconnect")
		Net.server_err=0
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("sure").connect("pressed",self,"_on_sure")
	pass
func _on_sure():
	hide()
func _on_show(msg=""):
	get_node("text").text=tr(msg)
	show()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
