@tool
extends Label

const SLIDER_WARNING = "SliderLabel needs to be a child of a Slider control (HSlider or VSlider), or slider property needs to point to one."

enum VisibilityRule { ON_CLICK, ON_HOVER, ON_FOCUS, ALWAYS }
enum Placement { TOP_RIGHT, BOTTOM_LEFT }

@export var visibility_rule: VisibilityRule = VisibilityRule.ON_HOVER
@export var placement: Placement = Placement.TOP_RIGHT
@export var separation := 4
@export var custom_format: String
@export var slider: Slider:
	set(sl):
		slider = sl
		update_configuration_warnings()

var _slider: Slider
var _vertical: bool

var _grabber_size: Vector2
var _center_grabber: bool

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			if Engine.is_editor_hint() and not get_meta(&"_edit_initialized_", false):
				set_meta(&"_edit_initialized_", true)
				horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				size_flags_horizontal = SIZE_SHRINK_CENTER
				text = "100"
		
		NOTIFICATION_THEME_CHANGED:
			_grabber_size = _slider.get_theme_icon(&"grabber").get_size()
			_center_grabber = _slider.get_theme_constant(&"center_grabber")
		
		NOTIFICATION_READY:
			if is_part_of_edited_scene():
				return
			
			if slider:
				_slider = slider
			else:
				_slider = get_parent() as Slider
			
			if not _slider:
				assert(_slider != null, SLIDER_WARNING)
			
			if _slider is VSlider:
				_vertical = true
			
			_slider.value_changed.connect(_update_label.unbind(1))
			
			if visibility_rule == VisibilityRule.ALWAYS:
				show()
			else:
				hide()
				
				match visibility_rule:
					VisibilityRule.ON_CLICK:
						_slider.gui_input.connect(_on_slider_gui_input)
					VisibilityRule.ON_HOVER:
						_slider.mouse_entered.connect(_on_slider_hover_focus.bind(true))
						_slider.mouse_exited.connect(_on_slider_hover_focus.bind(false))
					VisibilityRule.ON_FOCUS:
						_slider.focus_entered.connect(_on_slider_hover_focus.bind(true))
						_slider.focus_exited.connect(_on_slider_hover_focus.bind(false))
			
			_update_label.call_deferred()
		
		NOTIFICATION_PARENTED:
			update_configuration_warnings()
		
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree() and is_node_ready():
				_update_label.call_deferred()

func _update_label():
	if not is_visible_in_tree():
		return
	
	if custom_format.is_empty():
		text = str(_slider.value)
	else:
		text = custom_format % _slider.value
	
	reset_size()
	
	if _center_grabber:
		if _vertical:
			_grabber_size.y = 0
		else:
			_grabber_size.x = 0
	
	if _vertical:
		position.y = (1.0 - _slider.ratio) * (_slider.size.y - _grabber_size.y) + _grabber_size.y * 0.5 - size.y * 0.5
		if placement == Placement.TOP_RIGHT:
			position.x = _slider.size.x + separation
		else:
			position.x = -size.x - separation
	else:
		position.x = _slider.ratio * (_slider.size.x - _grabber_size.x) + _grabber_size.x * 0.5 - size.x * 0.5
		if placement == Placement.TOP_RIGHT:
			position.y = -size.y - separation
		else:
			position.y = _slider.size.y + separation

func _get_configuration_warnings() -> PackedStringArray:
	var ret: PackedStringArray
	
	if not slider and not get_parent() is Slider:
		ret.append(SLIDER_WARNING)
	
	return ret

func _on_slider_gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb:
		visible = mb.pressed
		_update_label()

func _on_slider_hover_focus(hover: bool):
	visible = hover
	_update_label()
