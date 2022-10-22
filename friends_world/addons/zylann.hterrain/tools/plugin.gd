tool
extends EditorPlugin


const HTerrain = preload("../hterrain.gd")#preload("hterrain.gdns")
const HTerrainData = preload("../hterrain_data.gd")
const Brush = preload("../hterrain_brush.gd")#preload("hterrain_brush.gdns")
const BrushDecal = preload("brush/decal.gd")
const Util = preload("../util/util.gd")
const LoadTextureDialog = preload("load_texture_dialog.gd")
const EditPanel = preload("panel.tscn")
const ProgressWindow = preload("progress_window.tscn")
const GeneratorDialog = preload("generator/generator_dialog.tscn")
const ImportDialog = preload("importer/importer_dialog.tscn")

const MENU_IMPORT_MAPS = 0
# TODO Save items two should not exist, they are workarounds to test saving!
const MENU_SAVE = 1
const MENU_LOAD = 2
const MENU_GENERATE = 3
const MENU_UPDATE_EDITOR_COLLIDER = 4


# TODO Rename _terrain
var _node = null

var _panel = null
var _toolbar = null
var _toolbar_brush_buttons = {}
var _brush = null
var _brush_decal = null
var _mouse_pressed = false

var _generator_dialog = null
var _import_dialog = null

var _progress_window = null

var _pending_paint_action = null
var _pending_paint_completed = false


static func get_icon(name):
	return load("res://addons/zylann.hterrain/tools/icons/icon_" + name + ".svg")


func _enter_tree():
	print("Heightmap plugin Enter tree")
	
	add_custom_type("HTerrain", "Spatial", HTerrain, get_icon("heightmap_node"))
	add_custom_type("HTerrainData", "Resource", HTerrainData, get_icon("heightmap_data"))
	
	_brush = Brush.new()
	_brush.set_radius(5)

	_brush_decal = BrushDecal.new()
	_brush_decal.set_shape(_brush.get_shape())
	_brush.connect("shape_changed", _brush_decal, "set_shape")
	
	var editor_interface = get_editor_interface()
	var base_control = editor_interface.get_base_control()
	var load_texture_dialog = LoadTextureDialog.new()
	base_control.add_child(load_texture_dialog)
	
	_panel = EditPanel.instance()
	_panel.hide()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, _panel)
	# Apparently _ready() still isn't called at this point...
	_panel.call_deferred("set_brush", _brush)
	_panel.call_deferred("set_load_texture_dialog", load_texture_dialog)
	_panel.connect("detail_selected", self, "_on_detail_selected")
	_panel.connect("texture_selected", self, "_on_texture_selected")
	
	_toolbar = HBoxContainer.new()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _toolbar)
	_toolbar.hide()
	
	var menu = MenuButton.new()
	menu.set_text("Terrain")
	menu.get_popup().add_item("Import maps...", MENU_IMPORT_MAPS)
	menu.get_popup().add_item("Generate...", MENU_GENERATE)
	menu.get_popup().add_separator()
	menu.get_popup().add_item("Save", MENU_SAVE)
	menu.get_popup().add_item("Load", MENU_LOAD)
	menu.get_popup().add_separator()
	menu.get_popup().add_item("Update Editor Collider", MENU_UPDATE_EDITOR_COLLIDER)
	menu.get_popup().connect("id_pressed", self, "_menu_item_selected")
	_toolbar.add_child(menu)
	
	var mode_icons = {}
	mode_icons[Brush.MODE_ADD] = get_icon("heightmap_raise")
	mode_icons[Brush.MODE_SUBTRACT] = get_icon("heightmap_lower")
	mode_icons[Brush.MODE_SMOOTH] = get_icon("heightmap_smooth")
	mode_icons[Brush.MODE_FLATTEN] = get_icon("heightmap_flatten")
	# TODO Have different icons
	mode_icons[Brush.MODE_SPLAT] = get_icon("heightmap_paint")
	mode_icons[Brush.MODE_COLOR] = get_icon("heightmap_color")
	mode_icons[Brush.MODE_DETAIL] = get_icon("grass")
	mode_icons[Brush.MODE_MASK] = get_icon("heightmap_mask")
	
	var mode_tooltips = {}
	mode_tooltips[Brush.MODE_ADD] = "Raise"
	mode_tooltips[Brush.MODE_SUBTRACT] = "Lower"
	mode_tooltips[Brush.MODE_SMOOTH] = "Smooth"
	mode_tooltips[Brush.MODE_FLATTEN] = "Flatten"
	mode_tooltips[Brush.MODE_SPLAT] = "Texture paint"
	mode_tooltips[Brush.MODE_COLOR] = "Color paint"
	mode_tooltips[Brush.MODE_DETAIL] = "Grass paint"
	mode_tooltips[Brush.MODE_MASK] = "Cut holes"
	
	_toolbar.add_child(VSeparator.new())
	
	# I want modes to be in that order in the GUI
	var ordered_brush_modes = [
		Brush.MODE_ADD,
		Brush.MODE_SUBTRACT,
		Brush.MODE_SMOOTH,
		Brush.MODE_FLATTEN,
		Brush.MODE_SPLAT,
		Brush.MODE_COLOR,
		Brush.MODE_DETAIL,
		Brush.MODE_MASK
	]
	
	var mode_group = ButtonGroup.new()
	
	for mode in ordered_brush_modes:
		var button = ToolButton.new()
		button.icon = mode_icons[mode]
		button.set_tooltip(mode_tooltips[mode])
		button.set_toggle_mode(true)
		button.set_button_group(mode_group)
		
		if mode == _brush.get_mode():
			button.set_pressed(true)
		
		button.connect("pressed", self, "_on_mode_selected", [mode])
		_toolbar.add_child(button)
		
		_toolbar_brush_buttons[mode] = button
	
	_generator_dialog = GeneratorDialog.instance()
	_generator_dialog.connect("progress_notified", self, "_terrain_progress_notified")
	base_control.add_child(_generator_dialog)

	_import_dialog = ImportDialog.instance()
	base_control.add_child(_import_dialog)

	_progress_window = ProgressWindow.instance()
	base_control.add_child(_progress_window)


func _exit_tree():
	pass


func handles(object):
	return object is HTerrain


func edit(object):
	print("Edit ", object)
	
	var node = null
	if object != null and object is HTerrain:
		node = object
	
	if _node != null:
		_node.disconnect("tree_exited", self, "_terrain_exited_scene")
		_node.disconnect("progress_notified", self, "_terrain_progress_notified")
	
	_node = node
	
	if _node != null:
		_node.connect("tree_exited", self, "_terrain_exited_scene")
		_node.connect("progress_notified", self, "_terrain_progress_notified")
	
	_panel.set_terrain(_node)
	_generator_dialog.set_terrain(_node)
	_import_dialog.set_terrain(_node)
	_brush_decal.set_terrain(_node)


func make_visible(visible):
	_panel.set_visible(visible)
	_toolbar.set_visible(visible)
	_brush_decal.set_visible(visible)


func forward_spatial_gui_input(p_camera, p_event):
	if _node == null || _node.get_data() == null:
		return false
	
	_node._edit_set_manual_viewer_pos(p_camera.global_transform.origin)
	
	var captured_event = false
	
	if p_event is InputEventMouseButton:
		var mb = p_event
		
		if mb.button_index == BUTTON_LEFT or mb.button_index == BUTTON_RIGHT:
			if mb.pressed == false:
				_mouse_pressed = false

			# Need to check modifiers before capturing the event,
			# because they are used in navigation schemes
			if (not mb.control) and (not mb.alt) and mb.button_index == BUTTON_LEFT:
				if mb.pressed:
					_mouse_pressed = true
				
				captured_event = true
				
				if not _mouse_pressed:
					# Just finished painting
					_pending_paint_completed = true

	elif p_event is InputEventMouseMotion:
		var mm = p_event
		
		var screen_pos = mm.position
		var origin = p_camera.project_ray_origin(screen_pos)
		var dir = p_camera.project_ray_normal(screen_pos)
		
		var hit_pos_in_cells = [0, 0]
		if _node.cell_raycast(origin, dir, hit_pos_in_cells):
			
			_brush_decal.set_position(Vector3(hit_pos_in_cells[0], 0, hit_pos_in_cells[1]))
			
			if _mouse_pressed:
				if Input.is_mouse_button_pressed(BUTTON_LEFT):
					
					# Deferring this to be done once per frame,
					# because mouse events may happen more often than frames,
					# which can result in unpleasant stuttering/freezes when painting large areas
					_pending_paint_action = [hit_pos_in_cells[0], hit_pos_in_cells[1]]
					
					captured_event = true

	return captured_event


func _process(delta):
	if _node != null:
		if _pending_paint_action != null:
			var override_mode = -1
			_brush.paint(_node, _pending_paint_action[0], _pending_paint_action[1], override_mode)

		if _pending_paint_completed:
			paint_completed()

	_pending_paint_completed = false
	_pending_paint_action = null


func paint_completed():
	var heightmap_data = _node.get_data()
	assert(heightmap_data != null)
	
	var ur_data = _brush._edit_pop_undo_redo_data(heightmap_data)
	
	var ur = get_undo_redo()
	
	var action_name = ""
	match ur_data.channel:
		
		HTerrainData.CHANNEL_COLOR:
			action_name = "Modify HeightMapData Color"
			
		HTerrainData.CHANNEL_SPLAT:
			action_name = "Modify HeightMapData Splat"
			
		HTerrainData.CHANNEL_HEIGHT:
			action_name = "Modify HeightMapData Height"

		HTerrainData.CHANNEL_DETAIL:
			action_name = "Modify HeightMapData Detail"
			
		_:
			action_name = "Modify HeightMapData"
	
	var undo_data = {
		"chunk_positions": ur_data.chunk_positions,
		"data": ur_data.redo,
		"channel": ur_data.channel,
		"index": ur_data.index,
		"chunk_size": ur_data.chunk_size
	}
	var redo_data = {
		"chunk_positions": ur_data.chunk_positions,
		"data": ur_data.undo,
		"channel": ur_data.channel,
		"index": ur_data.index,
		"chunk_size": ur_data.chunk_size
	}

	ur.create_action(action_name)
	ur.add_do_method(heightmap_data, "_edit_apply_undo", undo_data)
	ur.add_undo_method(heightmap_data, "_edit_apply_undo", redo_data)

	# Small hack here:
	# commit_actions executes the do method, however terrain modifications are heavy ones,
	# so we don't really want to re-run an update in every chunk that was modified during painting.
	# The data is already in its final state,
	# so we just prevent the resource from applying changes here.
	heightmap_data._edit_set_disable_apply_undo(true)
	ur.commit_action()
	heightmap_data._edit_set_disable_apply_undo(false)


func _terrain_exited_scene():
	print("HTerrain exited the scene")
	edit(null)


func _menu_item_selected(id):
	print("Menu item selected ", id)
	match id:
		
		MENU_IMPORT_MAPS:
			_import_dialog.popup_centered_minsize()
			
		MENU_SAVE:
			var data = _node.get_data()
			if data != null:
				data.save_data_async()
			
		MENU_LOAD:
			var data = _node.get_data()
			if data != null:
				data.load_data_async()
			
		MENU_GENERATE:
			_generator_dialog.popup_centered_minsize()
			
		MENU_UPDATE_EDITOR_COLLIDER:
			# This is for editor tools to be able to use terrain collision.
			# It's not automatic because keeping this collider up to date is expensive,
			# but not too bad IMO because that feature is not often used in editor for now.
			# If users complain too much about this, there are ways to improve it:
			#
			# 1) When the terrain gets deselected, update the terrain collider in a thread automatically.
			#    This is still expensive but should be easy to do.
			#
			# 2) Bullet actually support modifying the heights dynamically as long as we stay within min and max bounds,
			#    so PR a change to the Godot heightmap collider to support passing a Float Image directly,
			#    and make it so the data is in sync (no CoW plz!!). It's trickier than 1).
			#
			_node.update_collider()


func _on_mode_selected(mode):
	print("On mode selected ", mode)
	_brush.set_mode(mode)
	_panel.set_brush_editor_display_mode(mode)


func _on_texture_selected(index):
	# Switch to texture paint mode when a texture is selected
	_select_brush_mode(Brush.MODE_SPLAT)
	_brush.set_texture_index(index)


func _on_detail_selected(index):
	# Switch to detail paint mode when a detail item is selected
	_select_brush_mode(Brush.MODE_DETAIL)
	_brush.set_detail_index(index)


func _select_brush_mode(mode):
	_toolbar_brush_buttons[mode].pressed = true
	_on_mode_selected(mode)


static func get_size_from_raw_length(flen):
	var side_len = round(sqrt(float(flen/2)))
	return int(side_len)


func _terrain_progress_notified(info):
	#print("Plugin received: ", info.message, ", ", int(info.progress * 100.0), "%")
	
	if info.has("finished") and info.finished:
		_progress_window.hide()
	
	else:
		if not _progress_window.visible:
			_progress_window.popup_centered_minsize()
		
		var message = ""
		if info.has("message"):
			message = info.message
		
		_progress_window.show_progress(info.message, info.progress)
		# TODO Have builtin modal progress bar


