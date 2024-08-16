extends Button

signal button_1_pressed
signal button_2_pressed

@onready var button_1: Button = %Button1
@onready var button_2: Button = %Button2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_buttons() -> void:
	$AnimationPlayer.play("show")
	
func hide_buttons() -> void:
	$AnimationPlayer.play_backwards("show")


func _on_button_1_pressed() -> void:
	button_1_pressed.emit()


func _on_button_2_pressed() -> void:
	button_2_pressed.emit()
