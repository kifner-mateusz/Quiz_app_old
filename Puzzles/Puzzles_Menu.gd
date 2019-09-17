extends ScrollContainer

var VButton = preload("res://Assets/CustomNodes/VButton.tscn")
var Quiz = preload("res://Quiz/Quiz.tscn")

func _ready():
	Puzzle.connect("puzzle_list_updated",self,"puzzle_list_show")
	
func puzzle_list_show():
	for i in $icons.get_children():
		i.queue_free()
	for i in Puzzle.puzzle_list:
		var new_puzzle_button = VButton.instance()
		new_puzzle_button.text = i["puzzle_name"]
		new_puzzle_button.texture = load("res://Assets/Images/icons/" + i["puzzle_icon"])
		new_puzzle_button.margin = 30
		new_puzzle_button.padding = 40
		new_puzzle_button.connect("pressed",self,"start_puzzle",[i["puzzle_id"]])
		var new_center_conteiner = CenterContainer.new()
		new_center_conteiner.add_child(new_puzzle_button)
		$icons.add_child(new_center_conteiner)
		
	if(User.is_admin):
		var new_puzzle_button = VButton.instance()
		new_puzzle_button.text = "New Puzzle"
		new_puzzle_button.texture = load("res://Assets/Images/icons/gear_white128.png")
		new_puzzle_button.margin = 30
		new_puzzle_button.padding = 40
		new_puzzle_button.connect("pressed",self,"start_puzzle",[0])
		var new_center_conteiner = CenterContainer.new()
		new_center_conteiner.add_child(new_puzzle_button)
		$icons.add_child(new_center_conteiner)
		
		
func start_puzzle(id):
	var new_quiz = Quiz.instance()
	get_tree().get_root().get_node("Main/MainMenu").animate_out()
	get_tree().get_root().get_node("Main").add_child(new_quiz)
	Puzzle.update_current_puzzle_data(id)
	if(User.is_admin):
		Puzzle.update_current_puzzle_ans(id)
	
	