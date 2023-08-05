extends Control

const ProjectData = preload("res://src/ProjectData.gd")

onready var _graph_view = $MainView/Spliter/Right/GraphView
onready var _variable_view = $MainView/Spliter/Left/Variables

var _project : ProjectData = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_project = ProjectData.new()
	_graph_view.set_project(_project)
	_variable_view.set_project(_project)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AddVariable_pressed():
	_project.add_float_variable(0.0)
	_variable_view.update_variables()
	#_graph_view.update()
