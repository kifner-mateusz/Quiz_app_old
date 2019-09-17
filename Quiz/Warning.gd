extends Control

func _ready():
	pass


func _on_Back_pressed():
	visible = false
	get_parent().get_parent().get_node("Menu").visible = true


func _on_Quit_pressed():
	get_tree().get_root().get_node("Main/MainMenu").animate_in()
	get_parent().get_parent().queue_free()
