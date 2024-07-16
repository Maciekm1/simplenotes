class_name Section
extends Slot

@export var extra_slots: Array[Slot] = []

# Function to add a task or section to the section
func add_slot(slot: Slot):
	extra_slots.append(slot)
