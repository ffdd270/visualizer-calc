extends ColorRect

const CursorItem = preload("res://src/CursorItem.gd")
const ProjectData = preload("res://src/ProjectData.gd")

const CursorItemScene = preload("res://scenes/CursorItem.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var _container = get_parent() as Control
var _project : ProjectData = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_project(project): 
	_project = project

func _update_cursors_list():
	var cursor_names : Array = _project.get_variables()
	var index := get_index() + 1
	
	for i in len(cursor_names):
		var cname := cursor_names[i] as String
		var c = _project.get_cursor_by_name(cname)
		
		var ci
		if index < _container.get_child_count():
			ci = _container.get_child(index)
		
		if ci == null or not (ci is CursorItem):
			ci = CursorItemScene.instance()
			ci.connect("clicked", self, "_on_cursor_item_clicked", [ci])
			ci.connect("value_changed", self, "_on_cursor_value_changed", [ci])
			ci.connect("settings_clicked", self, "_on_cursor_settings_clicked", [ci])
			_container.add_child(ci)
			_container.move_child(ci, index)
		
		ci.set_item_name(i)
		ci.set_cursor_range(c.min_value, c.max_value, c.step)
		ci.set_cursor_value(c.value)
		ci.set_selected(i)
		
		index += 1
	
	while index < _container.get_child_count():
		var child = _container.get_child(index)
		if child is CursorItem:
			child.queue_free()
		index += 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


