extends ColorRect

const CursorItem = preload("res://src/CursorItem.gd")
const ProjectData = preload("res://src/ProjectData.gd")

const CursorItemScene = preload("res://scenes/CursorItem.tscn")

signal command_selected(cname)
signal variable_changed
signal variable_settings_requested(cname)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var _container = get_parent() as Control
var _project : ProjectData = null
var _min_value = -100
var _max_value = 100
var _step = 0.1
var _selected_varaible_name = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_project(project): 
	_project = project

func update_variables():
	_update_varaible_list()

func _update_varaible_list():
	var varaibles := _project.get_variable_list()
	var index := get_index() + 1
	
	for i in len(varaibles):
		var c = varaibles[i]
		var ci
		if index < _container.get_child_count():
			ci = _container.get_child(index)
		
		# 없으면 만들고 훅업.
		if ci == null or not (ci is CursorItem):
			ci = CursorItemScene.instance()
			ci.connect("clicked", self, "_on_variable_item_clicked", [ci])
			ci.connect("value_changed", self, "_on_varaible_value_changed", [ci])
			ci.connect("settings_clicked", self, "_on_varaible_settings_clicked", [ci])
			_container.add_child(ci)
			_container.move_child(ci, index)
		
		ci.set_item_name(c.variable_name)
		ci.set_cursor_range(_min_value, _max_value, _step)
		ci.set_cursor_value(c.variable)
		ci.set_selected(c.variable_name == _selected_varaible_name)
		
		index += 1
	
	while index < _container.get_child_count():
		var child = _container.get_child(index)
		if child is CursorItem:
			child.queue_free()
		index += 1

func _on_variable_item_clicked(varaible_item): 
	_selected_varaible_name = varaible_item.get_item_name()
	_update_varaible_list()
	emit_signal("cursor_selected", _selected_varaible_name)

func _on_varaible_value_changed(value, varaible_item):
	_project.set_variable(varaible_item.get_item_name(), value)
	emit_signal("variable_changed")

func select_variable(cname: String):
	if _selected_varaible_name == cname:
		return
	_selected_varaible_name = cname
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is CursorItem:
			child.set_selected(child.get_item_name() == cname)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


