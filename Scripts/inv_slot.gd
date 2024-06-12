extends TextureRect

@export var accessible = true
@export var empty = true
func  _ready():
	if not accessible:
		texture = null
		empty = true
	
func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(60,60)
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)
	accessible = false
	return self 
func _can_drop_data(at_position, data):
	if data is TextureRect and not accessible:
		return true
	return false
func _drop_data(at_position, data):
	texture = data.texture
	data.texture = null
	accessible = true
