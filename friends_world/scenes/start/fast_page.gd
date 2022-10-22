extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("sure").connect("pressed",self,"_on_sure")
	get_node("close").connect("pressed",self,"_on_close")
	get_node("../loading/canel").connect("pressed",self,"_on_canel")
func _on_sure():
	var name_=$name/text.text
	if name_:
		Overall.my_info.name=name_
		Net.connect_server("132.232.18.164",21240)
		get_node("../loading").show()
func _on_close():
	hide()
func _on_canel():
	Net.close_connect()
	get_node("../loading").hide()