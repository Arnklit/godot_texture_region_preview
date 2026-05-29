@tool
extends PanelContainer

var node: Object
var checkerboard_tex: Texture2D

var texture: Texture2D
var region: Rect2
var pm_left: int
var pm_top: int
var pm_right: int
var pm_bottom: int


func _init(p_node: Object) -> void:
	node = p_node


func _enter_tree() -> void:
	checkerboard_tex = EditorInterface.get_base_control().get_theme_icon("Checkerboard", "EditorIcons")


func _process(delta: float) -> void:
	# Slightly annoying and hacky, but it's not really possible to tie into a signal whether these change
	var new_texture := node.get("texture") as Texture2D
	var new_rect := node.get("region_rect") as Rect2

	if node is NinePatchRect:
		var new_pm_left := (node as NinePatchRect).patch_margin_left
		var new_pm_top := (node as NinePatchRect).patch_margin_top
		var new_pm_right := (node as NinePatchRect).patch_margin_right
		var new_pm_bottom := (node as NinePatchRect).patch_margin_bottom
		if new_pm_left != pm_left or new_pm_top != pm_top or new_pm_right != pm_right or new_pm_bottom != pm_bottom:
			pm_left = new_pm_left
			pm_top = new_pm_top
			pm_right = new_pm_right
			pm_bottom = new_pm_bottom
			queue_redraw()

	if new_texture == texture and new_rect == region:
		return

	texture = new_texture
	region = new_rect
	queue_redraw()


func _draw() -> void:
	if not texture:
		custom_minimum_size = Vector2() # Collapse if no texture is assigned
		return
	custom_minimum_size = Vector2(0, 256) 
	draw_texture_rect(checkerboard_tex, Rect2(Vector2(), size), true)

	var ratio := texture.get_size().x / texture.get_size().y
	var horizontal = ratio > 1
	var new_preview_rect: Rect2
	var new_scale := 1.0
	if (horizontal):
		new_preview_rect.size = Vector2(size.x, size.x / ratio)
		new_preview_rect.position = Vector2(0.0, size.y / 2.0 - new_preview_rect.size.y / 2.0)
		new_scale = size.x / texture.get_size().x
	else:
		new_preview_rect.size = Vector2(size.y * ratio, size.y)
		new_preview_rect.position = Vector2(size.x / 2.0 - new_preview_rect.size.x / 2.0, 0.0)
		new_scale = size.y / texture.get_size().y

	draw_texture_rect(texture, new_preview_rect, false)

	var scaled_rect := region
	if scaled_rect == Rect2():
		# If the rect's value i 0, we draw the rect around the whole texture like the region editor.
		scaled_rect = new_preview_rect
	else:
		scaled_rect.position *= new_scale
		scaled_rect.size *= new_scale
		scaled_rect.position += new_preview_rect.position
	draw_rect(scaled_rect, Color.WHITE, false)

	# NinePatch
	if node is NinePatchRect:
		var scaled_pm_left := pm_left * new_scale + scaled_rect.position.x
		var scaled_pm_top := pm_top * new_scale + scaled_rect.position.y
		var scaled_pm_right := scaled_rect.end.x - pm_right * new_scale
		var scaled_pm_bottom := scaled_rect.end.y - pm_bottom * new_scale
		draw_dashed_line(Vector2(scaled_pm_left, 0), Vector2(scaled_pm_left, size.y), Color.WHITE, -1.0, 8.0)
		draw_dashed_line(Vector2(0, scaled_pm_top), Vector2(size.x, scaled_pm_top), Color.WHITE, -1.0, 8.0)
		draw_dashed_line(Vector2(scaled_pm_right, 0), Vector2(scaled_pm_right, size.y), Color.WHITE, -1.0, 8.0)
		draw_dashed_line(Vector2(0, scaled_pm_bottom), Vector2(size.x, scaled_pm_bottom), Color.WHITE, -1.0, 8.0)
