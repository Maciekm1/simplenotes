class_name EditField
extends Control

var slot: Control
@onready var title_edit: LineEdit = %TitleEdit
@onready var close_button: Button = %CloseButton
@onready var canvas_layer: CanvasLayer = $CanvasLayer

signal on_text_changed(new_text)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.visible = false
	visible = false
	get_tree().get_root().connect("go_back_requested", on_close)
	close_button.pressed.connect(on_close)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_open():
	canvas_layer.visible = true
	visible = true
	title_edit.call_deferred('grab_focus')
	title_edit.text = slot.label.text
	
func on_close():
	canvas_layer.visible = false
	visible = false
	title_edit.deselect()

func _on_title_edit_text_changed(new_text: String) -> void:
	on_text_changed.emit(new_text)


func _on_title_edit_text_submitted(new_text: String) -> void:
	on_close()
