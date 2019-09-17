extends HBoxContainer

var hide = false

func _ready():
	pass

func _on_hide_pressed():
	if hide:
		for child in range(1,get_child_count()):
			get_child(child).visible = false
		hide = false
	else:
		for child in range(1,get_child_count()):
			get_child(child).visible = true
		hide = true


func _on_Login_pressed():
	_clear()
	get_parent().find_node("LogIn").visible = true
	get_parent().find_node("LogIn")._ready()



func _on_Quiz_pressed():
	_clear()
	get_parent().find_node("Quiz").visible = true


func _on_Main_pressed():
	_clear()
	get_parent().find_node("MainMenu").visible = true

func _clear():
	for i in range(get_parent().get_child_count()-1):
		get_parent().get_child(i).visible = false
	rect_size = Vector2()
	margin_right = 0
	margin_left = 0
	