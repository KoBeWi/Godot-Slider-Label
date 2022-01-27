tool
extends Label

const SLIDER_WARNING = "SliderLabel needs to be a child of a Slider control (HSlider or VSlider)."
const SLIDER_WARNING2 = "custom_slider_path needs to point to a Slider control (HSlider or VSlider)."

enum VisibilityRule {ON_CLICK, ON_HOVER, ON_FOCUS, ALWAYS}
enum Placement {TOP_RIGHT, BOTTOM_LEFT}

export(VisibilityRule) var visibility_rule: int = VisibilityRule.ON_HOVER
export(Placement) var placement: int = Placement.TOP_RIGHT
export var separation := 4
export var custom_format := ""
export var custom_slider_path: NodePath setget set_custom_path

var slider: Slider
var vertical: bool

func _enter_tree() -> void:
	if not has_meta("_edit_initialized_"):
		set_meta("_edit_initialized_", true)
		align = Label.ALIGN_CENTER
		valign = Label.VALIGN_CENTER
		size_flags_horizontal = SIZE_SHRINK_CENTER
		text = "100"

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if custom_slider_path.is_empty():
		slider = get_parent() as Slider
	else:
		slider = get_node(custom_slider_path) as Slider
	assert(slider != null, SLIDER_WARNING)
	
	if slider is VSlider:
		vertical = true
	
	slider.connect("value_changed", self, "update_with_discard")
	
	if visibility_rule == VisibilityRule.ALWAYS:
		show()
	else:
		hide()
		
		match visibility_rule:
			VisibilityRule.ON_CLICK:
				slider.connect("gui_input", self, "_on_slider_gui_input")
			VisibilityRule.ON_HOVER:
				slider.connect("mouse_entered", self, "_on_slider_hover_focus", [true])
				slider.connect("mouse_exited", self, "_on_slider_hover_focus", [false])
			VisibilityRule.ON_FOCUS:
				slider.connect("focus_entered", self, "_on_slider_hover_focus", [true])
				slider.connect("focus_exited", self, "_on_slider_hover_focus", [false])
	
	update_label()

func _on_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		visible = event.pressed
		update_label()

func _on_slider_hover_focus(hover: bool):
	visible = hover
	update_label()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warning()

func update_with_discard(discard):
	update_label()

func update_label():
	if not is_visible_in_tree():
		return
	
	if custom_format.empty():
		text = str(slider.value)
	else:
		text = custom_format % slider.value
	
	hide()
	show()
	rect_size = Vector2()
	
	var grabber_size := slider.get_icon("Grabber").get_size()
	if vertical:
		rect_position.y = (1.0 - slider.ratio) * (slider.rect_size.y - grabber_size.y) + grabber_size.y * 0.5 - rect_size.y * 0.5
		if placement == Placement.TOP_RIGHT:
			rect_position.x = slider.rect_size.x + separation
		else:
			rect_position.x = -rect_size.x - separation
	else:
		rect_position.x = slider.ratio * (slider.rect_size.x - grabber_size.x) + grabber_size.x * 0.5 - rect_size.x * 0.5
		if placement == Placement.TOP_RIGHT:
			rect_position.y = -rect_size.y - separation
		else:
			rect_position.y = slider.rect_size.y + separation

func _get_configuration_warning() -> String:
	if custom_slider_path.is_empty():
		if not get_parent() is Slider:
			return SLIDER_WARNING
	else:
		if not get_node(custom_slider_path) is Slider:
			return SLIDER_WARNING2
	return ""

func set_custom_path(path: NodePath):
	custom_slider_path = path
	update_configuration_warning()
