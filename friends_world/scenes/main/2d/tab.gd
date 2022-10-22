extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var label=load("res://assets/tscn/ui/text.tscn")
func _ready():
	add_to_group("tap")
	set_process_input(true)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func _check():
	for data in $scroll/v.get_children():
		data.queue_free()
	for key in Net.player_info:
		var tscn=label.instance()
		tscn.text=Net.player_info[key].name
		tscn.get_node("num").text=str(Net.player_info[key].kill)+"/"+str(Net.player_info[key].dead)
		$scroll/v.add_child(tscn)
func _input(event):
	if event.is_action_pressed("tab"):
		show()
		_check()
	if event.is_action_released("tab"):
		hide()
		
			
			
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
