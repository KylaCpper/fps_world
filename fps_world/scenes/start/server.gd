extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("sure").connect("pressed",self,"_on_sure")
	get_node("close").connect("pressed",self,"_on_close")

func _on_sure():
	var port=get_node("port/text").text
	var num=get_node("num/text").text
	var name_=$name/text.text
	if port&&num&&name_:
		Overall.my_info.name=name_
		Net.create_server(port,num)
		Net.port=port
		Global.GoTo_Scene("res://scenes/main/main.tscn")
func _on_close():
	hide()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
