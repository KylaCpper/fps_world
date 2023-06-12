tool
extends Control


# Emitted when a texture item is selected
signal texture_selected(index)

# Emitted when a detail item is selected (grass painting)
signal detail_selected(index)


onready var _minimap = get_node("HSplitContainer/HSplitContainer/Minimap")
onready var _brush_editor = get_node("HSplitContainer/BrushEditor")
onready var _texture_editor = get_node("HSplitContainer/HSplitContainer/HSplitContainer/TextureEditor")
onready var _detail_editor = get_node("HSplitContainer/HSplitContainer/HSplitContainer/DetailEditor")


func set_terrain(terrain):
	_minimap.set_terrain(terrain)
	_texture_editor.set_terrain(terrain)
	_detail_editor.set_terrain(terrain)


func set_brush(brush):
	_brush_editor.set_brush(brush)


func set_load_texture_dialog(dialog):
	_texture_editor.set_load_texture_dialog(dialog)


func _on_TextureEditor_texture_selected(index):
	emit_signal("texture_selected", index)


func _on_DetailEditor_detail_selected(index):
	emit_signal("detail_selected", index)


func set_brush_editor_display_mode(mode):
	_brush_editor.set_display_mode(mode)

