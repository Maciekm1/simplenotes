class_name SectionUI
extends Control

var section: Section
var task_ui_scene: PackedScene
var section_ui_scene: PackedScene
var section_node: PanelContainer
var slot_container: VBoxContainer

var old_min_size: Vector2
var new_min_size: Vector2

@export var extra_slots: Array[Slot] = []
@export var slot_height: float = 75
@export var slot_separation: float = 10

@onready var expand_section_button: Button = $SectionNode/NodeMarginContainer/HBoxContainer/ExpandMarginContainer/ExpandSectionButton
var expanded: bool = true

func _ready() -> void:
	expand_section_button.pressed.connect(on_expand_button_pressed)
	
func _process(delta: float) -> void:
	pass
	
func visualise_slots(n: int) -> void:
	task_ui_scene = preload("res://Scenes/taskUI.tscn")
	section_ui_scene = preload("res://Scenes/sectionUI.tscn")
	
	for slot in extra_slots:
		if slot is Task:
			var new_task_ui = task_ui_scene.instantiate() as TaskUI
			new_task_ui.set_task(slot)
			new_task_ui.size.x = 540 - (40 * n)
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
		

func add_task() -> void:
	pass

func set_section(s: Section) -> void:
	var label: Label = %TitleLabel
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
	expanded = !expanded
	if expanded:
		for c in slot_container.get_children():
			c.visible = true
	else:
		for c in slot_container.get_children():
			c.visible = false
	update_min_size()
