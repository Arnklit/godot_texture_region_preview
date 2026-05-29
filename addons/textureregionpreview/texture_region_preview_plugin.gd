@tool
extends EditorPlugin

var region_inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	region_inspector_plugin = preload("region_inspector_plugin.gd").new()
	add_inspector_plugin(region_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(region_inspector_plugin)
