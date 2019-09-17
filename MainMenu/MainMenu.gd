extends VBoxContainer

onready var tween = $Tween

func _ready():
	User.connect("user_data_updated",self,"update_data")
	$Menu/Button3.connect("pressed",User,"update_user_grades_data")
	
func update_data():
	if(User.user_data_set):
		$Welcome.text = "Witaj, " + User.user_data['name'] + "!"

func animate_out():
	tween.interpolate_property(self,"modulate",Color(1.0,1.0,1.0,1.0),Color(1.0,1.0,1.0,0.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	
func animate_in():
	tween.interpolate_property(self,"modulate",Color(1.0,1.0,1.0,0.0),Color(1.0,1.0,1.0,1.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()