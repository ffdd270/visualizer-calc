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

var DEFAULT_POINT_SIZE = 0.05 
var points = []

# Engine Callback Functions
func _ready():
	points.append( PointRender.new(Vector2(0 , 0), Color(1, 1, 1, 1), 0.05, "v1", label, self) )
	points.append( PointRender.new(Vector2(0.5, 0), Color(0.5, 1, 0.5, 1), 0.05, "v2", label, self) )
	points.append( PointRender.new(Vector2(1, 0), Color(0.5, 0.5, 0.5, 1), 0.05, "v3", label, self) )


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

func _draw():	
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	# 이 때 이걸로 올바른 사이즈로 리폼한다. 
	var pixel_view_offset = Vector2(-_view_offset.x, _view_offset.y) * _view_scale
	draw_set_transform(size / 2 + pixel_view_offset, 0, Vector2(_view_scale.x, -_view_scale.y))

	# 격자 그리기
	_draw_grid()

	# 점 그리기
	for i in points:
		var pixel_pos = (i._pos) * _view_scale
		var parent_pos = size / 2 + pixel_view_offset 
		var label_offset = Vector2(0, 5)
		i._label.rect_position = parent_pos + pixel_pos + label_offset
		#i._label.scale = Vector2(_view_scale.x, -_view_scale.y)
		#i._label.rect_position.x = pixel_pos.x
		#i._label.rect_position.y = pixel_pos.y
		draw_circle(i._pos*_grid_step, i._size, i._color)


# --- User Defined Functions
# Privates

func _pixel_to_graph_position(ppos):
	return (Vector2(ppos.x, rect_size.y - ppos.y) - rect_size / 2) / _view_scale + _view_offset

# Publics 
func set_project(project):
	_project = project
	

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

