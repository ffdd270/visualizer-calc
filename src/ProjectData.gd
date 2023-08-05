class_name ProjectData

class FloatVariable: 
	var variable_color : Color = Color(1,1,1,1)
	var variable_name : String = ""
	var variable : float = 0.0

class Commands:
	var command_color = Color(1,1,1,1)
	var command_name = ""
	var command = ""


var _variables : Array = []
var _commands : Array = []


func add_float_variable(number : float):
	var new_variable = FloatVariable.new()
	var lenght = len(_variables)
	new_variable.variable = number
	new_variable.variable_name = "v" +  str(lenght)
	new_variable.variable_color = Color(1 - (lenght/10),1, 1 - (lenght/10),1)
	_variables.append(new_variable)

func set_variable(varirable_name : String, value : float):
	for variable in _variables:
		if variable.variable_name == varirable_name:
			variable.variable = value
			return

	print("NOT FOUND VARIABLE : " + varirable_name)

func get_variable_length():
	return len(_variables)

func get_variable_list() -> Array:
	return _variables

func add_command(command : String):
	var new_command = Commands.new()
	new_command.command = command
	new_command.command_name = "c" + str(len(_commands))
	_commands.append(new_command)

func get_command_list() -> Array:
	return _commands

func get_command_length():
	return len(_commands)
