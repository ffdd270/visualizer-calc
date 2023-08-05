tool 
extends ColorRect

export(PackedScene) var label = null

const X_AXIS_COLOR = Color(1, 0.5, 0.5)
const Y_AXIS_COLOR = Color(0.5, 1.0, 0.5)

var _view_scale = Vector2(100, 100)
var _view_offset = Vector2(0, 0)
var _grid_color = Color(1, 1, 1, 0.15)
var _grid_step = Vector2(1, 1)
var _project = null

var DEFAULT_POINT_SIZE = 0.2
var points = []
var render_points = []
var commands = []

# Engine Callback Functions
func _ready():
	commands.append(Command.new("c1", "x*2"))
	commands.append(Command.new("c1", "pow(2, x)"))
	commands.append(Command.new("c1", "sin(x)+cos(x)"))
	commands.append(Command.new("c1", "log(x)"))


func _gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			_view_offset += Vector2(-event.relative.x, event.relative.y) / _view_scale
			update()
	elif event is InputEventMouseButton:
		var factor = 1.1
		match event.button_index:
			BUTTON_WHEEL_UP:
				_add_zoom(factor, event.position)
			BUTTON_WHEEL_DOWN:
				_add_zoom(1.0 / factor, event.position)
				
func _draw_grid():
	var step = _grid_step
	# 그래프 최소값? 
	var gmin = _pixel_to_graph_position(Vector2(0, rect_size.y)).snapped(step) - step

	# 그래프 최대값? 
	var gmax = _pixel_to_graph_position(Vector2(rect_size.x, 0)).snapped(step) + step
	
	# 몇번 그려야 하는지 계산하기.
	var counts = rect_size / (_view_scale * step)

	# 현재 보이는 최대 숫자까지 그리기
	var max_counts = rect_size / 2
	
	# X축 격자
	if counts.x < max_counts.x:
		var x = gmin.x
		while x < gmax.x:
			draw_line(Vector2(x, gmin.y), Vector2(x, gmax.y), _grid_color)
			x += step.x
	
	# Y축 격자 
	if counts.y < max_counts.y:
		var y = gmin.y
		while y < gmax.y:
			draw_line(Vector2(gmin.x, y), Vector2(gmax.x, y), _grid_color)
			y += step.y

	# X and Y axis
	draw_line(Vector2(gmin.x, 0), Vector2(gmax.x, 0), X_AXIS_COLOR)
	draw_line(Vector2(0, gmin.y), Vector2(0, gmax.y), Y_AXIS_COLOR)

func _process(_delta):
	if Engine.editor_hint:
		update()

# 특정 노드의 Custom Render를 추가할 수 있어요
func _draw():	
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	# 이 때 이걸로 올바른 사이즈로 리폼한다. 
	var pixel_view_offset = Vector2(-_view_offset.x, _view_offset.y) * _view_scale
	draw_set_transform(size / 2 + pixel_view_offset, 0, Vector2(_view_scale.x, -_view_scale.y))

	# 격자 그리기
	_draw_grid()

	# 이미 있는 노드 탐색.
	var exist_name_hash = {}
	for i in len(points):
		exist_name_hash[points[i].get_text()] = i

	if (_project == null): 
		return

	# 프로젝트에서 데이터를 가져옴. 새로 온 거면 추가. 
	var variables = _project.get_variable_list()

	# for v in variables:
	# 	var value = v.variable
	# 	var color = v.variable_color
	# 	var text =  v.variable_name
	# 	# 지금은 모두 Float이라고 가정
	# 	var pos = Vector2(value, 0)

	# 	# 있다면 생성
	# 	if not exist_name_hash.has(text):
	# 		var point = PointRender.new(pos, color, DEFAULT_POINT_SIZE, text, label, self)
	# 		points.append(point)
	# 	else: # 없다면 갱신
	# 		var index = exist_name_hash[text]
	# 		points[index].update(pos, color, text)

	# 명령들 실행하기 
	var expressions = []
	var var_inputs = []
	var_inputs.resize(1)
	for command in commands:
		var expression := Expression.new()
		var err = expression.parse(command.command, ["x"])
		if err != OK:
			print("Error: ", err)
			continue

		expressions.append(expression)

	var expression_context = ExpressionContext.new(expressions, var_inputs)
	# 렌더링 포인트들 초기화
	for i in render_points:
		i._label.queue_free()

	render_points = []
	for v in variables:
		var value = v.variable
		var color = v.variable_color
		var text =  v.variable_name
		# 지금은 모두 Float이라고 가정
		var pos = Vector2(0, value)

		var origin_text = text + ":" + str(value)
		render_points.append(PointRender.new(pos, color, DEFAULT_POINT_SIZE, origin_text, label, self))

		var exp_count = 0
		for expression in expressions:
			var_inputs[0] = value
			var result = expression.execute(var_inputs, expression_context, false)
			var c_pos = Vector2(exp_count + 1, result)
			value = result
			var new_text = text + ":" +  str(result) + ":" + commands[exp_count].command
			render_points.append(PointRender.new(c_pos, color, DEFAULT_POINT_SIZE, new_text, label, self))
			exp_count = exp_count + 1


	# 시작점 그리기
	for i in render_points:
		var gpos = i.get_pos()
		#gpos.y -= _view_offset.y
		
		var pixel_pos = (gpos) * _view_scale
	
		#var pixel_pos = _grpah_to_pixel_position(i.get_pos())

		var label_offset = Vector2(20, 40)
		label_offset = label_offset #* _view_scale
		pixel_pos += label_offset

		var parent_pos = size / 2 + pixel_view_offset 

		pixel_pos.y = - pixel_pos.y
		i._label.rect_position = parent_pos + pixel_pos 
		draw_circle(i.get_pos()*_grid_step, i.get_size(), i.get_color())


# --- User Defined Functions
# Privates

func _pixel_to_graph_position(ppos):
	return (Vector2(ppos.x, rect_size.y - ppos.y) - rect_size / 2) / _view_scale + _view_offset

func _grpah_to_pixel_position(gpos):
	return (Vector2(gpos.x, gpos.y) + rect_size / 2) * _view_scale - _view_offset

# Publics 
func set_project(project):
	_project = project
	

func _add_zoom(factor, mpos):
	var gpos = _pixel_to_graph_position(mpos)
	_view_scale *= factor
	var gpos2 = _pixel_to_graph_position(mpos)
	_view_offset += gpos - gpos2
	update()
	
# --- Render Data Classes

class PointRender:
	var _pos  : Vector2  = Vector2(0, 0)
	var _color : Color = Color(1, 1, 1, 1)
	var _size : float = 0.05
	var _label : TransformLabel = null
	var _text : String = ""

	func _init(pos : Vector2, color : Color, size : float, text : String, label : PackedScene, parent : CanvasItem):
		_pos = pos
		_color = color
		_size = size
		_label = label.instance()
		_text = text
		_label.text = _text
		parent.add_child(_label)

	func get_text():
		return _text

	func get_pos():
		return _pos

	func get_size():
		return _size

	func get_color():
		return _color

	func update(pos : Vector2, color : Color, text : String):
		_pos = pos
		_color = color
		_text = text
		_label.text = _text

class Command: 
	var command_name = ""
	var command = ""

	func _init(command_name, command):
		self.command_name = command_name
		self.command = command


class CommandsExecutedPoint:
	var points : Array = []

	func _init():
		pass
	

# Oh joy, Expression's function binding is class based.
class ExpressionContext:
	var _expressions : Array
	var _var_inputs : Array
	
	func _init(expressions, var_inputs):
		_var_inputs = var_inputs
		_expressions = expressions
		
	func _internal_exec(i: int, x: float):
		var e = _expressions[i]
		if e == null:
			return
		var args = _var_inputs.duplicate()
		args[0] = x
		return e.execute(args, self, false)
		
	func f(x):
		return _internal_exec(0, x)

	func g(x):
		return _internal_exec(1, x)

	func h(x):
		return _internal_exec(2, x)

	func i(x):
		return _internal_exec(3, x)

	func j(x):
		return _internal_exec(4, x)

	func k(x):
		return _internal_exec(5, x)

	func l(x):
		return _internal_exec(6, x)

	func m(x):
		return _internal_exec(7, x)
