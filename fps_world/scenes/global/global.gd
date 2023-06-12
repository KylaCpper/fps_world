extends Node

var current_scene = null
#var noise_gd=preload("res://scene/lib/noise.gd")
#var resource=preload("res://scene/lib/resource_queue.gd")
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
var loader
func GoTo_Scene(path,load_scene=0):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:
	if(load_scene):
		if(path):
			call_deferred("GoTo_Scene_Deferred",path)
		loader = ResourceLoader.load_interactive(load_scene)
#		aa(load_scene)
#		self.path=load_scene
		set_process(true)
	else:
		call_deferred("GoTo_Scene_Deferred",path)
var time_max=0.5
var pro=0
var noise=null
func _process(delta):
#	
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	"""
	if wait_frames > 0: # wait for frames to let the "loading" animation to show up
		wait_frames -= 1
		 return
	"""
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread
		# poll your loader
		var err = loader.poll()
		if err == ERR_FILE_EOF: # load finished
			#切换场景
			var resource = loader.get_resource()
			loader = null
			current_scene.queue_free()
			current_scene = resource.instance()
			get_tree().get_root().add_child(current_scene)
			get_tree().set_current_scene( current_scene )
					
			pro=0
			break
		elif err == OK:
			pro = float(loader.get_stage()) / loader.get_stage_count()*100
		else: # error during loading
			loader = null
			break
		
#	if queue == null:
#		# no need to process anymore
#		set_process(false)
#		return
#	if queue.is_ready(path):
#		current_scene.queue_free()
#		current_scene = queue.get_resource(path).instance()
#		
#		get_tree().get_root().add_child(current_scene)
#		get_tree().set_current_scene( current_scene )
#		pro=0
#		queue.cancel_resource(path)
#		queue=null
#		return
#	else:
#	    pro=queue.get_progress(path)
#		# no need to process anymore
		
func GoTo_Scene_err(path):

    # Immediately free the current scene,
    # there is no risk here.
	current_scene.queue_free()

    # Load new scene

	var scene_be = ResourceLoader.load(path)

    # Instance the new scene
	current_scene = scene_be.instance()

    # Add it to the active scene, as child of root
    
	get_tree().get_root().add_child(current_scene)
    
    # optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( current_scene )
	current_scene._on_show("server_err")
func GoTo_Scene_Deferred(path):

    # Immediately free the current scene,
    # there is no risk here.
    current_scene.queue_free()

    # Load new scene

    var scene_be = ResourceLoader.load(path)

    # Instance the new scene
    current_scene = scene_be.instance()

    # Add it to the active scene, as child of root
    
    get_tree().get_root().add_child(current_scene)
    
    # optional, to make it compatible with the SceneTree.change_scene() API
    get_tree().set_current_scene( current_scene )
