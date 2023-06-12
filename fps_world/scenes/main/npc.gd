extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
func _on_event(id):
	if Net.status:
		if Net.id==id:
			Function.msg_group("shop","display")
	else:
		Function.msg_group("shop","display")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
