class_name Task
extends Slot

@export_multiline var description: String
@export var Priority: PriorityLevel
@export var Effort: EffortLevel
@export var created_date: String
@export var complete_by_date: String
@export var completed: bool

enum PriorityLevel {
	LOW,
	MEDIUM,
	HIGH
}

enum EffortLevel {
	LOW,
	MEDIUM,
	HIGH
}

# Constructor to initialize default values
func _init(description: String = "", priority: PriorityLevel = PriorityLevel.MEDIUM, effort: EffortLevel = EffortLevel.MEDIUM, complete_by_date: String = ""):
	self.description = description
	self.Priority = priority
	self.Effort = effort
	self.created_date = Time.get_datetime_string_from_system()
	self.complete_by_date = complete_by_date
	self.completed = false
