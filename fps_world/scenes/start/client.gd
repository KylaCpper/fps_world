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
	var ip=get_node("ip/text").text
	var port=get_node("port/text").text
	var name_=$name/text.text
	if ip&&port&&name_:
		Overall.my_info.name=name_
		Net.connect_server(ip,port)
		get_node("../loading").show()
		
func _on_close():
	hide()
func _on_canel():
	Net.close_connect()
	get_node("../loading").hide()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
