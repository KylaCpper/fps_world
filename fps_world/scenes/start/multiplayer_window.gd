extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("create").connect("pressed",self,"_on_create")
	get_node("connect").connect("pressed",self,"_on_connect")
	get_node("cannel").connect("pressed",self,"_on_cannel")
	pass
func _on_create():
	hide()
	get_node("../server").show()
func _on_connect():
	hide()
	get_node("../client").show()
func _on_cannel():
	hide()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
