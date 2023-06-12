extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	add_to_group("shop")
	$shop/buy1.connect("button_down",self,"_on_press1")
	$shop/buy2.connect("button_down",self,"_on_press2")
	$shop/buy3.connect("button_down",self,"_on_press3")
	pass
func display():
	Overall._gui("shop",!Overall.shop)
	if Overall.shop:
		show()
	else:
		hide()
func _on_press1():
	Function.msg_group("msg","_code","buy_bullet 1")
func _on_press2():
	Function.msg_group("msg","_code","buy_bullet 5")
func _on_press3():
	Function.msg_group("msg","_code","buy_bullet 10")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
