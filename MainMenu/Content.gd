extends Control

var current_index = 0
onready var tween = get_parent().get_node("Tween")

func _ready():
	for child in range(get_child_count()):
		get_child(child).rect_position = Vector2(get_viewport_rect().size.x*child,0)
	get_parent().get_node("Menu/Button").connect("pressed",self,"animate_to",[0])
	get_parent().get_node("Menu/Button2").connect("pressed",self,"animate_to",[1])
	get_parent().get_node("Menu/Button3").connect("pressed",self,"animate_to",[2])

func animate_to(index):
	tween.interpolate_property(self,"rect_position",rect_position,Vector2(-get_viewport_rect().size.x*index,rect_position.y),0.3,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	tween.start()