tool
extends MarginContainer
signal pressed
export var texture:Texture
export var text:String = ""
export var margin:int = 30
export var padding:int = 40


func _ready():
	if texture is Texture:
		$MarginContainer/VBoxContainer/Texture.texture = texture
	if text == "":
		$MarginContainer/VBoxContainer/Text.visible = false
	else:
		$MarginContainer/VBoxContainer/Text.text = text
	
	$MarginContainer.set("custom_constants/margin_top", padding)
	$MarginContainer.set("custom_constants/margin_bottom", padding)
	$MarginContainer.set("custom_constants/margin_right", padding)
	$MarginContainer.set("custom_constants/margin_left", padding)
	
	set("custom_constants/margin_top", margin)
	set("custom_constants/margin_bottom", margin)
	set("custom_constants/margin_right", margin)
	set("custom_constants/margin_left", margin)

func _on_Button_pressed():
	emit_signal("pressed")