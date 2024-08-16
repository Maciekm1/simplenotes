class_name SectionUI
extends Control

var section: Section
var task_ui_scene: PackedScene
var section_ui_scene: PackedScene
var section_node: PanelContainer
var slot_container: VBoxContainer
var edit_field: EditField
var label: Label

var old_min_size: Vector2
var new_min_size: Vector2
var depth: int

var is_held: bool = false
var old_pos: Vector2
var offset: Vector2
var mouse_start_pos: Vector2
var mouse_end_position: Vector2

@export var max_number_of_slots: int = 12

@export var extra_slots: Array[Slot] = []
@export var slot_height: float = 75
@export var slot_separation: float = 10

@onready var expand_section_button: TextureButton = %ExpandSectionButton
@onready var add_task_button: Button = %AddTaskButton
#@onready var completed_button: Button = %CompletedButton
@onready var tap_timer: Timer = $TapTimer

var expanded: bool = true:
	set(b):
		expanded = b
		expand_section_button.button_pressed = !b

func _ready() -> void:
	expand_section_button.pressed.connect(on_expand_button_pressed)
	add_task_button.pressed.connect(on_add_task_button_pressed)
	#completed_button.pressed.connect(on_slot_delete)
	
	if depth == 0:
		depth = get_parent().get_parent().depth + 1
	
func _process(delta: float) -> void:
	if is_held:
		section_node.global_position = get_global_mouse_position() + offset
	
func visualise_slots(n: int) -> void:
	depth = n
	task_ui_scene = preload("res://Scenes/taskUI.tscn")
	section_ui_scene = preload("res://Scenes/sectionUI.tscn")
	
	for slot in extra_slots:
		if slot is Task:
			var new_task_ui = task_ui_scene.instantiate() as TaskUI
			new_task_ui.set_task(slot)
			new_task_ui.size.x = 540 - (40 * n)
			new_task_ui.task_ui_panel = new_task_ui.get_children()[0]
			new_task_ui.task_ui_panel.size.x = 540 - (40 * n)
			new_task_ui.task_ui_panel.position = Vector2(new_task_ui.task_ui_panel.position.x + (20 * n), 0)
			slot_container.add_child(new_task_ui)
			
		if slot is Section:
			var new_section_ui: SectionUI = section_ui_scene.instantiate()
			new_section_ui.set_section(slot)
			new_section_ui.visualise_slots(n+1)
			new_section_ui.size.x = 540 - (40 * n)
			new_section_ui.section_node.size.x = 540 - (40 * n)
			new_section_ui.section_node.position = Vector2(new_section_ui.section_node.position.x + (20 * n), 0)
			new_section_ui.slot_container.size.x = section_node.size.x - (40 * (n+1))
			new_section_ui.slot_container.position.x = new_section_ui.section_node.position.x + 40
			slot_container.add_child(new_section_ui)
		

func set_section(s: Section) -> void:
	edit_field = %EditField
	edit_field.on_text_changed.connect(on_edit_field_title_text_changed)
	edit_field.slot = self
	label = %TitleLabel
	section = s
	label.text = s.title
	extra_slots = s.extra_slots
	slot_container = $SlotContainer
	section_node = $SectionNode
	slot_container.position.y += slot_separation
	slot_container.add_theme_constant_override("separation", slot_separation)
	
	old_min_size = custom_minimum_size
	custom_minimum_size.y += ((slot_height + slot_separation) * get_number_slots(s))

# Returns number of slots recursively (of s Section)
func get_number_slots(s: Section):
	var n: int = 0
	for t in s.extra_slots:
		if t is Task:
			n += 1
		if t is Section:
			n += 1
			n += get_number_slots(t)
	return n
	
func get_number_visible_slots(s: SectionUI):
	var n: int = 0
	for c in s.slot_container.get_children():
		if c.visible and c is TaskUI:
			n += 1
		if c.visible and c is SectionUI:
			n += 1
			n += get_number_visible_slots(c)
	return n
	
func update_min_size():
	custom_minimum_size.y = old_min_size.y + ((slot_height + slot_separation) * get_number_visible_slots(self))
	
	var parent = get_parent().get_parent()
	if parent != null and parent is SectionUI:
		parent.update_min_size()

func on_expand_button_pressed():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	expanded = !expanded
	if expanded:
		tween.tween_property(expand_section_button, 'rotation_degrees', 0, .2)
		for c in slot_container.get_children():
			c.visible = true
	else:
		tween.tween_property(expand_section_button, 'rotation_degrees', -90, .2)
		for c in slot_container.get_children():
			c.visible = false
	update_min_size()

func on_add_task_button_pressed() -> void:
	var new_task = Task.new("", Task.PriorityLevel.MEDIUM, Task.EffortLevel.MEDIUM, "")
	new_task.title = ""
	section.add_slot(new_task)
	add_task(new_task)

func on_slot_delete() -> void:
	var sectionUI = get_parent().get_parent() as SectionUI
	if sectionUI == null:
		print(str(self) + " is not a child of a section!")
		return
	section = sectionUI.section as Section
	sectionUI.remove_slot(self)
	section.remove_slot(section)

func add_task(t: Task) -> bool:
	task_ui_scene = preload("res://Scenes/taskUI.tscn")
	if len(extra_slots) > max_number_of_slots or depth > 5:
		return false
	if !expanded:
		on_expand_button_pressed()
	var new_task_ui = task_ui_scene.instantiate() as TaskUI
	new_task_ui.set_task(t)
	new_task_ui.size.x = 540 - (40 * depth)
	new_task_ui.task_ui_panel = new_task_ui.get_children()[0]
	new_task_ui.task_ui_panel.size.x = 540 - (40 * depth)
	new_task_ui.task_ui_panel.position = Vector2(new_task_ui.task_ui_panel.position.x + (20 * depth), 0)
	slot_container.add_child(new_task_ui)
	#slot_container.move_child(new_task_ui, 0)
	update_min_size()
	return true
	
func add_section(s: Section) -> bool:
	section_ui_scene = preload("res://Scenes/sectionUI.tscn")
	if len(extra_slots) > max_number_of_slots or depth > 5:
		return false
	if !expanded:
		on_expand_button_pressed()
	var new_section_ui = section_ui_scene.instantiate() as SectionUI
	new_section_ui.set_section(s)
	new_section_ui.size.x = 540 - (40 * depth)
	new_section_ui.section_node.size.x = 540 - (40 * depth)
	new_section_ui.section_node.position = Vector2(new_section_ui.section_node.position.x + (20 * depth), 0)
	new_section_ui.slot_container.size.x = 500 - (40 * depth)
	new_section_ui.slot_container.position.x = new_section_ui.section_node.position.x + 40
	slot_container.add_child(new_section_ui)
	update_min_size()
	return true

func remove_slot(s: Control) -> bool:
	for slot in slot_container.get_children():
		if slot == s:
			slot_container.remove_child(slot)
			update_min_size()
			return true
	return false

func on_add_section_button_pressed() -> void:
	if len(section.extra_slots) > max_number_of_slots or depth > 5:
		return
	var new_section = Section.new()
	new_section.title = ""
	section.add_slot(new_section)
	add_section(new_section)

func _on_task_ui_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse"):
		mouse_start_pos = get_global_mouse_position()
		old_pos = section_node.global_position
		offset = -get_global_mouse_position() + old_pos
		section_node.global_position = get_global_mouse_position() + offset
		is_held = true
		tap_timer.start()
	if event.is_action_released("mouse"):
		mouse_end_position = get_global_mouse_position()
		is_held = false
		section_node.global_position = old_pos
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
			get_parent().move_child(self, closest_node.get_index())
				
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
	section.title = new_text
