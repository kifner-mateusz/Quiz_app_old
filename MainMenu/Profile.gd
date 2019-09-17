extends TextureButton

func _on_Profile_pressed():
	get_node("/root/Main/UserSettings")._on_Enter_pressed()
