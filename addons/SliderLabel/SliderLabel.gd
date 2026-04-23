## Label for displaying current value of a [Slider].
##
## [SliderLabel] displays value of a [Slider] node in real time. By default it will display the parent [Slider] and follow its grabber.
@tool
class_name SliderLabel extends Label

const _SLIDER_WARNING = "SliderLabel needs to be a child of a Slider control (HSlider or VSlider), or has a Slider assigned in slider property."

enum VisibilityRule {
	## The label is visible when [Slider] is being dragged.
	ON_DRAG,
	## The label is visible when [Slider] is hovered.
	ON_HOVER,
	## The label is visible when [Slider] is hovered or dragged.
	ON_HOVER_DRAG,
	## The label is visible when [Slider] is focused.
	ON_FOCUS,
	## The label is always visible.
	ALWAYS,
}

enum Placement {
	## Top of HSlider, right of VSlider.
	TOP_RIGHT,
	## Bottom of HSlider, left of VSlider.
	BOTTOM_LEFT
}

## Determines when the label is visible.
@export var visibility_rule: VisibilityRule = VisibilityRule.ON_HOVER_DRAG:
	set(vr):
		if visibility_rule == vr:
			return
		visibility_rule = vr
		if _slider and _slider.value_changed.is_connected(_update_label):
			_disconnect_signals()
			_connect_signals()

## Determines label placement in relation to the [Slider]. Ignored when [member slider] is assigned.
@export var placement: Placement = Placement.TOP_RIGHT:
	set(p):
		if placement == p:
			return
		placement = p
		_update_label()

## The space in pixels between the label and the [Slider]. Ignored when [member slider] is assigned.
@export var separation := 4:
	set(s):
		if separation == s:
			return
		separation = s
		_update_label()

## Format string for displaying the text. [operator String.operator %] is used to format the slider's [member Range.value].
@export var custom_format: String:
	set(cf):
		if custom_format == cf:
			return
		custom_format = cf
		_update_label()

## Custom [Slider] node. If not assigned, the [SliderLabel] will try to use its parent. Assigning this property disables custom positioning.
@export var slider: Slider:
	set(s):
		if slider == s:
			return
		slider = s
		_update_slider()
		notify_property_list_changed()
		update_configuration_warnings()

var _slider: Slider
var _hover_drag_state: int

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
			
			if not is_part_of_edited_scene():
				if visibility_rule == VisibilityRule.ALWAYS:
					show()
					_update_label.call_deferred()
				else:
					hide()
			
		NOTIFICATION_THEME_CHANGED:
			assert(_slider, _SLIDER_WARNING)
			_grabber_size = _slider.get_theme_icon(&"grabber").get_size()
			_center_grabber = _slider.get_theme_constant(&"center_grabber")
		
		NOTIFICATION_PARENTED:
			_update_slider()
			update_configuration_warnings()
		
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree() and _slider:
				_update_label()

func _validate_property(property: Dictionary) -> void:
	if property["name"] == "text":
		property["usage"] = PROPERTY_USAGE_NONE
	elif slider and (property["name"] == "placement" or property["name"] == "separation"):
		property["usage"] |= PROPERTY_USAGE_READ_ONLY

func _get_configuration_warnings() -> PackedStringArray:
	if not slider and not get_parent() is Slider:
		return [_SLIDER_WARNING]
	
	return PackedStringArray()

func _update_slider():
	var new_slider := slider
	if not new_slider:
		new_slider = get_parent() as Slider
	
	if new_slider == _slider:
		return
	
	assert(new_slider, _SLIDER_WARNING)
	
	if _slider:
		_disconnect_signals()
	
	_slider = new_slider
	
	_connect_signals()

func _disconnect_signals():
	_slider.value_changed.disconnect(_update_label)
	
	if _slider.drag_started.is_connected(_on_slider_hover_focus):
		_slider.drag_started.disconnect(_on_slider_hover_focus)
	if _slider.drag_ended.is_connected(_on_slider_hover_focus):
		_slider.drag_ended.disconnect(_on_slider_hover_focus)
	if _slider.mouse_entered.is_connected(_on_slider_hover_focus):
		_slider.mouse_entered.disconnect(_on_slider_hover_focus)
	if _slider.mouse_exited.is_connected(_on_slider_hover_focus):
		_slider.mouse_exited.disconnect(_on_slider_hover_focus)
	if _slider.drag_started.is_connected(_on_slider_hover_drag):
		_slider.drag_started.disconnect(_on_slider_hover_drag)
	if _slider.drag_ended.is_connected(_on_slider_hover_drag):
		_slider.drag_ended.disconnect(_on_slider_hover_drag)
	if _slider.mouse_entered.is_connected(_on_slider_hover_drag):
		_slider.mouse_entered.disconnect(_on_slider_hover_drag)
	if _slider.mouse_exited.is_connected(_on_slider_hover_drag):
		_slider.mouse_exited.disconnect(_on_slider_hover_drag)
	if _slider.focus_entered.is_connected(_on_slider_hover_focus):
		_slider.focus_entered.disconnect(_on_slider_hover_focus)
	if _slider.focus_exited.is_connected(_on_slider_hover_focus):
		_slider.focus_exited.disconnect(_on_slider_hover_focus)

func _connect_signals():
	_slider.value_changed.connect(_update_label.unbind(1))
	
	match visibility_rule:
		VisibilityRule.ON_DRAG:
			_slider.drag_started.connect(_on_slider_hover_focus.bind(true))
			_slider.drag_ended.connect(_on_slider_hover_focus.bind(false).unbind(1))
		VisibilityRule.ON_HOVER:
			_slider.mouse_entered.connect(_on_slider_hover_focus.bind(true))
			_slider.mouse_exited.connect(_on_slider_hover_focus.bind(false))
		VisibilityRule.ON_HOVER_DRAG:
			_slider.mouse_entered.connect(_on_slider_hover_drag.bind(true, 1))
			_slider.mouse_exited.connect(_on_slider_hover_drag.bind(false, 1))
			_slider.drag_started.connect(_on_slider_hover_drag.bind(true, 2))
			_slider.drag_ended.connect(_on_slider_hover_drag.bind(false, 2).unbind(1))
		VisibilityRule.ON_FOCUS:
			_slider.focus_entered.connect(_on_slider_hover_focus.bind(true))
			_slider.focus_exited.connect(_on_slider_hover_focus.bind(false))

func _update_label() -> void:
	if not is_visible_in_tree():
		return
	
	if custom_format.is_empty():
		text = str(_slider.value)
	else:
		text = custom_format % _slider.value
	
	if slider:
		# Using custom slider, so no position adjustment.
		return
	
	reset_size()
	var vertical := (_slider is VSlider)
	
	if _center_grabber:
		if vertical:
			_grabber_size.y = 0
		else:
			_grabber_size.x = 0
	
	if vertical:
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

func _on_slider_hover_focus(hover: bool):
	visible = hover
	_update_label()

func _on_slider_hover_drag(hover: bool, mask: int):
	if hover:
		_hover_drag_state |= mask
	else:
		_hover_drag_state ^= mask
	
	visible = bool(_hover_drag_state)
	_update_label()
