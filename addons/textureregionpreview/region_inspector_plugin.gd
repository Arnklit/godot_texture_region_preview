@tool
extends EditorInspectorPlugin

const RegionPreview := preload("res://addons/textureregionpreview/preview.gd")

func _can_handle(object: Object) -> bool:
	if object is Sprite2D or object is Sprite3D or object is NinePatchRect:
		return true
	return false


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type == TYPE_RECT2:
		var region_inspector = MarginContainer.new()
		region_inspector.clip_contents = true
		var panel_container := RegionPreview.new(object)
		region_inspector.add_child(panel_container)
		add_custom_control(region_inspector)
	return false
