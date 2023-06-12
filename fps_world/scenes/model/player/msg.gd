extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	var n_hp = $"../Armature/hp"
	var m_hp=n_hp.get_node("hp1").material_override.duplicate()
	n_hp.get_node("hp1").material_override=m_hp
	n_hp.get_node("hp2").material_override=m_hp
	
	var m_msg=$msg/msg1.material_override.duplicate()
	$msg/msg1.material_override=m_msg
	$msg/msg2.material_override=m_msg
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	# Get the viewport and clear it
	var viewport = $Viewport
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport's is captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad
	$msg/msg1.material_override.albedo_texture = viewport.get_texture()
	$msg/msg2.material_override.albedo_texture = viewport.get_texture()
	
	var hp = $"../Armature/hp/Viewport"
	hp.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport's is captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the texture and set it to the viewport quad
	$"../Armature/hp/hp1".material_override.albedo_texture = hp.get_texture()
	$"../Armature/hp/hp2".material_override.albedo_texture = hp.get_texture()
	$time.connect("timeout",self,"_timeout")
	pass
func _show(text):
	show()
	$time.start()
	$Viewport/bg/text.text=text
	pass
func _timeout():
	hide()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
