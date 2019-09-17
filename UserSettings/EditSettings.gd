extends Control

func _ready():
	rect_position.y = get_viewport_rect().size.y/4
	for i in User.user_data.keys():
		var new_label = Label.new()
		new_label.text = i + " : " + User.user_data[i]
		add_child(new_label)

func _on_Button_pressed():
	User.update_data()
