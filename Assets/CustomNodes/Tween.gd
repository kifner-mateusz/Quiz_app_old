extends Tween

func _ready():
	pass

func fade_out():
	interpolate_property(get_parent(),"modulate",Color(1.0,1.0,1.0,1.0),Color(1.0,1.0,1.0,0.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	start()
	
func fade_in():
	interpolate_property(get_parent(),"modulate",Color(1.0,1.0,1.0,0.0),Color(1.0,1.0,1.0,1.0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	start()
	
func translate(from,to):
	interpolate_property(get_parent(),"rect_position",from,to,0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	start()
	
	
	
	