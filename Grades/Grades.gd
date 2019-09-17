extends ScrollContainer

var grade_template = preload("res://Grades/Grade_template.tscn")

func _ready():
	for i in $VBoxContainer.get_children():
		i.queue_free()
	User.connect("user_grades_data_updated",self,"show_grades")
#	Puzzle.connect("puzzle_list_updated",self,"show_grades")
	
func show_grades():
	for i in $VBoxContainer.get_children():
		i.queue_free()
	for p_id in User.user_grades_data.keys():
		print(User.user_grades_data[p_id], " = ", p_id)
		var score = User.user_grades_data[p_id]
		for puzzle in Puzzle.puzzle_list:
			if(puzzle["puzzle_id"] == p_id):
				var new_grade = grade_template.instance()
				new_grade.get_node("MarginContainer/HBoxContainer/TextureRect").texture = load("res://Assets/Images/icons/" + puzzle["puzzle_icon"])
				new_grade.get_node("MarginContainer/HBoxContainer/Label").text = puzzle["puzzle_name"]
				new_grade.get_node("MarginContainer/HBoxContainer/Label2").text = str(User.user_grades_data[p_id]["score"]) + " / " +  str(User.user_grades_data[p_id]["maxScore"])
				var new_sep = HSeparator.new()
				$VBoxContainer.add_child(new_sep)
				$VBoxContainer.add_child(new_grade)
				print(p_id, " : ",puzzle)
