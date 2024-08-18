class_name TaskUI
extends Control

var task: Task
var sectionUI: SectionUI
var edit_field: EditField

@onready var task_settings_button: Button = %TaskSettingsButton
@onready var completed_button: Button = %CompletedButton
@onready var tap_timer: Timer = $TapTimer
@onready var settings_image: TextureRect = $TaskUIPanel/MarginContainer/HBoxContainer/MarginContainer/HBoxContainer/TaskSettingsButton/SettingsImage

var task_ui_panel: PanelContainer
var label: Label

var is_held: bool = false
var old_pos: Vector2
var offset: Vector2

var mouse_start_pos: Vector2
var mouse_end_position: Vector2

func _ready() -> void:
	sectionUI = get_parent().get_parent() as SectionUI
	if sectionUI.depth > 4:
		task_settings_button.button_1.disabled = true
	task_settings_button.pressed.connect(on_settings_button_pressed)
	completed_button.pressed.connect(on_completed_button_pressed)
	task_settings_button.button_1_pressed.connect(on_change_to_section)

func _process(delta: float) -> void:
	if is_held:
		task_ui_panel.global_position = get_global_mouse_position() + offset

		
func set_task(t: Task) -> void:
	edit_field = %EditField
	edit_field.on_text_changed.connect(on_edit_field_title_text_changed)
	edit_field.slot = self
	label = %TitleLabel
	task = t
	label.text = t.title

func on_slot_delete() -> void:
	if sectionUI == null:
		print(str(self) + " is not a child of a section!")
		return
	var section = sectionUI.section as Section
	sectionUI.remove_slot(self)
	section.remove_slot(task)
	
func on_completed_button_pressed() -> void:
	task.completed = !task.completed
	
func on_change_to_section() -> bool:
	var self_index = get_index()
	on_slot_delete()
	var new_section = Section.new() as Section
	new_section.title = task.title
	sectionUI.add_section(new_section, self_index, self)
	sectionUI.section.add_slot(new_section)
	return true
	


func _on_task_ui_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse"):
		mouse_start_pos = get_global_mouse_position()
		task_ui_panel = %TaskUIPanel
		old_pos = task_ui_panel.global_position
		offset = -get_global_mouse_position() + old_pos
		task_ui_panel.global_position = get_global_mouse_position() + offset
		is_held = true
		z_index = -10
		task_ui_panel.z_index = -10
		#set_mouse_filter(Control.MOUSE_FILTER_PASS)
		#task_ui_panel.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		tap_timer.start()
	if event.is_action_released("mouse"):
		mouse_end_position = get_global_mouse_position()
		is_held = false
		task_ui_panel.global_position = old_pos
		if check_for_swipe(mouse_start_pos, mouse_end_position):
			return

	
		var mouse_position = get_global_mouse_position()
		var closest_node = null
		var closest_distance = 10000000000
		var parent = get_parent()
		if parent == null:
			return
		for node in parent.get_children():
			var distance = mouse_position.distance_to(node.global_position + node.size/2)
			if distance < closest_distance:
				closest_distance = distance
				closest_node = node

		if closest_node:
			print('\n')
			print(get_index())
			print('\n')
			print(closest_node.get_index())
			print('\n')
			swap_elements(parent.get_parent().section.extra_slots, get_index(), closest_node.get_index())
			sectionUI.slot_container.move_child(self, closest_node.get_index())
		
		#task_ui_panel.set_mouse_filter(Control.MouseFilter.MOUSE_FILTER_STOP)
		if !tap_timer.is_stopped():
			#label.text = 'edit mode ....'
			edit_field.on_open()
			

func check_for_swipe(start_pos, end_pos) -> bool:
	var direction = end_pos - start_pos
	var distance = direction.length()
	
	# Check if the distance is greater than a threshold to consider it a swipe
	if distance > 100:
		direction = direction.normalized()
		if abs(direction.x) > 0.8 and abs(direction.y) < 0.25:
			on_slot_delete()
			return true
	return false

func on_edit_field_title_text_changed(new_text: String):
	label.text = new_text
	task.title = new_text
	
func on_settings_button_pressed() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if task_settings_button.button_pressed:
		tween.tween_property(settings_image, 'rotation_degrees', -90, .2)
		task_settings_button.show_buttons()
	else:
		tween.tween_property(settings_image, 'rotation_degrees', 0, .2)
		task_settings_button.hide_buttons()

func swap_elements(arr, i, j):
	if i == j:
		return
	var temp = arr[i]
	arr[i] = arr[j]
	arr[j] = temp
