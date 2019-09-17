extends Control

onready var edit_settings = load("res://UserSettings/EditSettings.tscn")

func _ready():
	rect_position = Vector2(0,-get_viewport_rect().size.y-100)
	$Buttons.rect_position.y = get_viewport_rect().size.y/4
	User.connect("user_data_updated",self,"update_data")
	$Exit.connect("pressed",$Tween,"translate",[Vector2(0,0),Vector2(0,-get_viewport_rect().size.y-100)])
	$Buttons/ToggleAdmin.connect("pressed",User,"toggle_admin")
	$Buttons/EditProfile.connect("pressed",self,"_on_Enter_pressed")
	$Buttons/LogOut.connect("pressed",SessionManager,"logout")

func update_data():
	if(User.user_data_set):
		pass


func _on_Enter_pressed():
	if(User.is_admin):
		$Buttons/ToggleAdmin.disabled = false
	$Tween.translate(Vector2(0,-get_viewport_rect().size.y-100),Vector2(0,0))

func _on_EditProfile_pressed():
	var new_edit_settings = edit_settings.instance()
	get_tree().get_root().get_node("Main").add_child(new_edit_settings)
	new_edit_settings._on_Enter_pressed()