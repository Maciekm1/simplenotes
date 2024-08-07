class_name TaskUI
extends PanelContainer

var task: Task

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_task(t: Task):
	task = t
	var label: Label = %TitleLabel
	label.text = t.title
