extends Node2D

func _ready() -> void:
	# Create the main section
	var general_section = Section.new()
	general_section.title = "General"

	# Create a task for the General section using the constructor
	var task1 = Task.new("Remember to take out the trash before 8 PM.", Task.PriorityLevel.MEDIUM, Task.EffortLevel.LOW, "2024-07-17")
	task1.title = "Take out the trash"

	# Add the task to the General section
	general_section.add_slot(task1)

	# Create the Shopping section
	var shopping_section = Section.new()
	shopping_section.title = "Shopping"

	# Create tasks for the Shopping section using the constructor
	var task2 = Task.new("Buy fresh carrots from the market.", Task.PriorityLevel.LOW, Task.EffortLevel.LOW, "2024-07-18")
	task2.title = "Get carrots"

	var task3 = Task.new("Buy a gallon of milk.", Task.PriorityLevel.MEDIUM, Task.EffortLevel.LOW, "2024-07-18")
	task3.title = "Get milk"

	# Add tasks to the Shopping section
	shopping_section.add_slot(task2)
	shopping_section.add_slot(task3)

	# Add the Shopping section to the General section
	general_section.add_slot(shopping_section)

	# Print section and task details for testing purposes
	print("Section: ", general_section.title)
	for slot in general_section.extra_slots:
		if slot is Task:
			print_task_details(slot)
		elif slot is Section:
			print("Subsection: ", slot.title)
			for sub_slot in slot.extra_slots:
				print_task_details(sub_slot)

func print_task_details(task: Task) -> void:
	print("Task: ", task.title)
	print("Description: ", task.description)
	print("Priority: ", task.Priority)
	print("Effort: ", task.Effort)
	print("Created Date: ", task.created_date)
	print("Complete By Date: ", task.complete_by_date)
	print("Completed: ", task.completed)
	print("-----")

func _process(delta: float) -> void:
	pass
