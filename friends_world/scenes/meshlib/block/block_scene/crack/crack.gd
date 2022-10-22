extends MeshInstance

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var index=1
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_surface_material(0).duplicate()
	$time.connect("timeout",self,"_on_time_out")
	check_status()
	pass
func _on_time_out():
	queue_free()
func check_status():
	$time.start()
	get_surface_material(0).albedo_texture=load("res://assets/img/crack/crack"+String(index)+".png")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
