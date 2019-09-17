extends Node

signal quiz_data_updated
var quiz_data = {}
var quiz_data_set = false

signal current_puzzle_data_updated
var current_puzzle_data = {}
var current_puzzle_data_set = false

signal current_puzzle_ans_updated
var current_puzzle_ans = {}
var current_puzzle_ans_set = false

signal puzzle_list_updated
var puzzle_list = []
var puzzle_list_set = false

signal puzzle_status_data_updated
var puzzle_status_data = {}
var puzzle_status_data_set = false


func _ready():
	User.connect("user_data_updated",self,"update_puzzle_list")
	pass
	
func start_puzzle(id):
	puzzle_status_data = {}
	SessionManager._request("send_data.php",{"data":"puzzle","puzzle_status":"start","puzzle_id":id})

func answer_puzzle(question, answer:Array):
	puzzle_status_data = {}
	var json = "["
	for i in answer:
		json += str(i) + ","
	json = json.rstrip(",")
	json += "]"
	print(json)
	SessionManager._request("send_data.php",{"data":"puzzle","puzzle_status":"answer","puzzle_question_id":question,"puzzle_answer":json})


func end_puzzle():
	puzzle_status_data = {}
	SessionManager._request("send_data.php",{"data":"puzzle","puzzle_status":"end"})
	
func update_puzzle_list():
	puzzle_list = []
	SessionManager.get_data("puzzle_list")
		
func puzzle_list_is_set():
	puzzle_list_set = true
	emit_signal("puzzle_list_updated")

func update_quiz_data():
	quiz_data = {}
	SessionManager.get_data("quiz_data")
		
func quiz_data_is_set():
	quiz_data_set = true
	emit_signal("quiz_data_updated")

func update_current_puzzle_data(index):
	current_puzzle_data = {}
	SessionManager._request("get_data.php",{"data":"puzzle_data","index":index})

func update_current_puzzle_ans(index):
	current_puzzle_ans = {}
	SessionManager._request("get_data.php",{"data":"puzzle_ans","index":index})

func current_puzzle_data_is_set():
	current_puzzle_data_set = true
	emit_signal("current_puzzle_data_updated")
	
func current_puzzle_ans_is_set():
	if(not(current_puzzle_ans.empty())):
		current_puzzle_ans_set = true
		emit_signal("current_puzzle_ans_updated")
	
func puzzle_status_data_is_set():
	puzzle_status_data_set = true
	emit_signal("puzzle_status_data_updated")
	