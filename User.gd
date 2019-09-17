extends Node

signal user_data_updated
var user_data_set = false
var user_data = {}

signal user_grades_data_updated
var user_grades_data_set = false
var user_grades_data = {}

var is_admin = false
var admin_enable = false

func _ready():
	if SessionManager.is_logedin():
		if not(user_data_set):
			update_data()

func toggle_admin():
	if(User.admin_enable):
		User.admin_enable = false
	else:
		User.admin_enable = true
	SessionManager.save_tokens()
	get_tree().reload_current_scene()

func user_data_is_set():
	user_data_set = true
	emit_signal("user_data_updated")
	if(user_data["permission_access_lvl"].substr(2,1) == "f"):
		is_admin = true
	update_user_grades_data()
	
func user_grades_data_is_set():
	user_data_set = true
	emit_signal("user_grades_data_updated")

func update_data():
	user_data_set = false
	user_data = {}
	SessionManager.get_data("user")
	
func update_user_grades_data():
	user_grades_data_set = false
	user_grades_data = {}
#	SessionManager.get_data("user_grades")
	SessionManager.add_to_queue("get_data",["user_grades"])