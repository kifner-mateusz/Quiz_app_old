extends VBoxContainer

onready var tween = $Tween
onready var exercise = $Control/Exercise

var current_question = -1
var warn_message = false
var points:float = 0.0

func _ready():
	animate_in()
	points = 0.0
	$MarginContainer/MarginContainer/HBoxContainer/Section.text = "Quiz"
	Puzzle.connect("current_puzzle_data_updated",self,"set_start_screen")
	Puzzle.connect("puzzle_status_data_updated",self,"check_response")
	
func _process(delta):
	$MarginContainer/MarginContainer/HBoxContainer/Time.text = "%d" % $Timer.time_left

func set_start_screen():
	var elem
	var new_icon
	if(User.admin_enable):
		elem = Button
		new_icon = load("res://Assets/CustomNodes/VButton.tscn").instance()
#		new_icon.texture_normal = load("res://Assets/Images/icons/" + Puzzle.current_puzzle_data["puzzle_icon"])
		
	else:
		elem = Label
		new_icon = TextureRect.new()
		
	new_icon.texture = load("res://Assets/Images/icons/" + Puzzle.current_puzzle_data["puzzle_icon"])
	var new_center = CenterContainer.new()
	new_center.add_child(new_icon)
	exercise.add_child(new_center)
	var new_name = elem.new()
	new_name.text = Puzzle.current_puzzle_data["puzzle_name"]
	new_name.align = ALIGN_CENTER
	exercise.add_child(new_name)
	var new_description = elem.new()
	new_description.text = Puzzle.current_puzzle_data["puzzle_description"]
	new_description.align = ALIGN_CENTER
	exercise.add_child(new_description)
	var new_points = elem.new()
	new_points.text = str(Puzzle.current_puzzle_data["puzzle_question_count"]) + " points"
	new_points.align = ALIGN_CENTER	
	exercise.add_child(new_points)
	$Menu/Check.text = "Start"
	$MarginContainer/MarginContainer/HBoxContainer/Time.visible = true
	
	
func set_question():
	
	for i in exercise.get_children():
		i.queue_free()
	var new_question = Label.new()
	$MarginContainer/MarginContainer/HBoxContainer/Section.text = "Zadanie " + str(int(Puzzle.current_puzzle_data["puzzle_questions"][current_question]["question_id"])+1)
	new_question.text = Puzzle.current_puzzle_data["puzzle_questions"][current_question]["question_text"]
	exercise.add_child(new_question)
	var is_multi_choise = Puzzle.current_puzzle_data["puzzle_questions"][current_question]["question_is_multiple_choice"]
	var new_group
	if not(is_multi_choise):
		new_group = ButtonGroup.new()
	for ans in  Puzzle.current_puzzle_data["puzzle_questions"][current_question]["question_answers"]:
		var new_ans = CheckBox.new()
		new_ans.text = ans["answer_text"]
		if not(is_multi_choise):
			new_ans.group = new_group
		exercise.add_child(new_ans)
	$Timer.start(60.5)
	
func check():
	if (current_question <0):
		$Menu/Check.text = "Check"
		warn_message = true
		Puzzle.start_puzzle(Puzzle.current_puzzle_data["puzzle_id"])
	else:
		var ans = []
		for i in range(exercise.get_child_count()):
			if exercise.get_child(i) is CheckBox and exercise.get_child(i).pressed:
				ans.append(i-1)
		print(ans)
		Puzzle.answer_puzzle(current_question,ans)
	
func check_response():
	current_question +=1
	if("points" in Puzzle.puzzle_status_data):
			points += float(Puzzle.puzzle_status_data["points"])
	if (current_question >= Puzzle.current_puzzle_data["puzzle_question_count"]):
		Puzzle.disconnect("puzzle_status_data_updated",self,"check_response")
		exercise.visible = false
		$Control/End.visible = true
		warn_message = false
		$Control/End/Points.text = str(points) + " / " + str(Puzzle.current_puzzle_data["puzzle_question_count"])
		$Menu/Check.visible = false
		Puzzle.end_puzzle()
	else:
		set_question()
		pass
	
func animate_out():
	tween.interpolate_property(self,"modulate",Color(1.0,1.0,1.0,1.0),Color(1.0,1.0,1.0,0.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	
func animate_in():
	tween.interpolate_property(self,"modulate",Color(1.0,1.0,1.0,0.0),Color(1.0,1.0,1.0,1.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	

func _on_Back_pressed():
	if(warn_message):
		$Control/Warning.visible = true
		$Menu.visible = false
	else:
		get_tree().get_root().get_node("Main/MainMenu").animate_in()
		queue_free()


func _on_Timer_timeout():
	check()
