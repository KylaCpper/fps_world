extends Node
func _ready():
	pass
func GetSaveDataRow(filename,pwd=null):
	var file = File.new()
	if(!file.file_exists("user://"+filename)):return null
	if(!pwd):
		file.open("user://"+filename, File.READ)
	else:
		file.open_encrypted_with_pass("user://"+filename, File.READ,pwd)
	if(!file):return null
	var data={}
	var data_be=file.get_line()
	
	data.parse_json(data_be)
	file.close()
	return data
	pass
func SetSaveDataRow(filename,data,pwd=null):
	var file = File.new()
	if(!pwd):
		file.open("user://"+filename, File.WRITE)
	else:
		file.open_encrypted_with_pass("user://"+filename, File.WRITE,pwd)
	if(!file):return
	for i in range(data.size()):
		file.store_line(data[i])
	file.close()
	pass
func GetSaveData(filename,pwd=null):
	var file = File.new()
	if(!file.file_exists("user://"+filename)):return null
	if(!pwd):
		file.open("user://"+filename, File.READ)
	else:
		file.open_encrypted_with_pass("user://"+filename, File.READ,pwd)
	if(!file):return null
	var data=parse_json(file.get_as_text())
	file.close()
	if !data:return null

	return data
func SetSaveData(filename,data,pwd=null):
	var file = File.new()
	if(!pwd):
		file.open("user://"+filename, File.WRITE)
	else:
		file.open_encrypted_with_pass("user://"+filename, File.WRITE,pwd)
	if(!file):return 
	if data:
		file.store_string(to_json(data))
	file.close()
	pass
func get_dir(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var files=[]
		var folders=[]
		while (file_name != ""):
			if dir.current_is_dir():
				folders.append(file_name)
			else:
				files.append(file_name)
			file_name = dir.get_next()
		return {"files":files,"folders":folders}
	else:
		return null
func is_queue_free(obj):
	var wr = weakref(obj)
	var data=0
	if (!wr.get_ref()):
		data=1
	wr=null
	return data
func ray(ray,pos):
	ray.set_pos(pos)
	ray.force_raycast_update()
	if(ray.is_colliding()):
		var obj=ray.get_collider()
		if(obj.is_queued_for_deletion()):
			return null
		else:
			return obj
	else:
		return null
func msg_group(group,function,arg0=null,arg1=null,arg2=null,arg3=null,arg4=null):
	get_tree().call_group(group,function,arg0,arg1,arg2,arg3,arg4)