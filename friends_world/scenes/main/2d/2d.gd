extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	add_to_group("2d")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	pass
func _input(event):
	if event.is_action_pressed("enter"):
		$msg.display()
	elif event.is_action_pressed("code"):
		if !Overall.msg:
			$msg.display()
	elif event.is_action_pressed("esc"):
		if Overall.msg:
			$msg.display()
		elif Overall.shop:
			$shop.display()
		else:
			$esc.display()
func _on_dead():
	$dead.display()
func _on_hurt():
	$AnimationPlayer.play("hurt")
func _bullet(num,num_z):
	$gun/bullet.text=str(num)+"/"+str(num_z)
func _hp(num):
	$hp/text.text=str(num)
	$hp/hp.value=num
func _money(num):
	$money/text.text=str(num)
func _hit():
	$aim/ani.play("hit")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
