extends ColorRect

const FunctionItem = preload("res://src/FunctionItem.gd")
const FunctionItemScene = preload("res://scenes/FunctionItem.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var _container = get_parent() as Control
var _selected_command_name = ""
var _project : ProjectData = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_commands():
	_update_command_list()

func _update_command_list():
	var commands = _project.get_command_list()
	commands.sort()
	
	var index = get_index() + 1
	
	for i in len(commands):
		var f = commands[i]
		var fi = _container.get_child(index)
		
		if not fi is FunctionItem:
			fi = FunctionItemScene.instance()
			fi.connect("clicked", self, "_on_command_item_clicked", [fi])
			_container.add_child(fi)
			_container.move_child(fi, index)
			
		fi.set_label(f.command_name, f.command)
		fi.set_color(f.color)
		fi.set_selected(f.command_name == _selected_command_name)
		
		index += 1
	
	while index < get_index():
		var child = _container.get_child(index)
		if child is FunctionItem:
			child.queue_free()
			index += 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
