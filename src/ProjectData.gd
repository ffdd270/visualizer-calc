class_name ProjectData

class FloatVariable: 
	var varaible_name : String = ""
	var variable : float = 0.0


var _variables : Array = []



func add_float_variable(number : float):
	var new_variable = FloatVariable.new()
	new_variable.variable = number
	new_variable.varaible_name = "v" +  str(len(_variables))
	_variables.append(new_variable)

func get_variable_length():
	return len(_variables)

func get_variable_list() -> Array:
	return _variables
