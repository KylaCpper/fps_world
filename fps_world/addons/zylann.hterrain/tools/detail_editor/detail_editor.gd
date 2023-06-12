tool
extends Control

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

signal detail_selected(index)

onready var _item_list = get_node("ItemList")
onready var _edit_dialog = get_node("EditDetailDialog")
onready var _confirmation_dialog = get_node("ConfirmationDialog")

var _terrain = null
var _dialog_target = -1
var _empty_texture = load("res://addons/zylann.hterrain/tools/icons/empty.png")
var _placeholder_icon = load("res://addons/zylann.hterrain/tools/icons/icon_grass.svg")


func set_terrain(terrain):
	if _terrain == terrain:
		return
	
	_terrain = terrain
	
	_update_list()


func _update_list():
	_item_list.clear()
	
	if _terrain != null:
		var data = _terrain.get_data()
		if data != null:
			var layer_count = data.get_map_count(HTerrainData.CHANNEL_DETAIL)
			for i in range(layer_count):
				# TODO How do I make a preview here?
				_item_list.add_item(str(i), _placeholder_icon)


func _edit_detail(index):
	_dialog_target = index
	
	var texture = _terrain.get_detail_texture(_dialog_target)
	
	_edit_dialog.set_params(texture)
	_edit_dialog.popup_centered_minsize()


func _on_Add_pressed():
	_dialog_target = -1
	_edit_dialog.set_params(null)
	_edit_dialog.popup_centered_minsize()


func _on_Remove_pressed():
	_dialog_target = _item_list.get_selected_items()[0]
	_confirmation_dialog.popup_centered_minsize()


func _on_Edit_pressed():
	_edit_detail(_item_list.get_selected_items()[0])


func _on_EditDetailDialog_confirmed(params):
	var index = _dialog_target
	
	if _dialog_target == -1:
		var data = _terrain.get_data()
		index = data._edit_add_detail_map()

	_terrain.set_detail_texture(index, params.texture)

	if _dialog_target == -1:
		_update_list()


func _on_ConfirmationDialog_confirmed():
	var data = _terrain.get_data()
	data._edit_remove_detail_map(_dialog_target)
	_update_list()


func _on_ItemList_item_selected(index):
	emit_signal("detail_selected", index)


func _on_ItemList_item_activated(index):
	# Edit on double-click
	_edit_detail(index)


	
