extends Control

var http = HTTPClient.new()
onready var tween = $Tween

var form_visible = true
var form_completed = false

func _ready():
	$VBoxContainer/Title.rect_min_size.y = get_viewport().get_visible_rect().size.y/4
	rect_position = Vector2(0,0)
	if SessionManager.is_logedin():
		visible = false
		User.update_data()
	
func _on_AnimationPlayer_animation_changed(old_anim,new_anim=""):
	if(old_anim == "fade"):
		if form_visible:
			form_visible = false
		else:
			form_visible = true
			
func LogIn(text_from_password:String = ""):
	var password = $VBoxContainer/MarginContainer/VBoxContainer/Password.text
	var login = $VBoxContainer/MarginContainer/VBoxContainer/Login.text
	if(password.length()>=5 and login.length()>=5):
		$AnimationPlayer.play("fade")
		SessionManager.login(login,password)
		form_completed = true
	else:
		if password.length()<5:
			$VBoxContainer/MarginContainer/VBoxContainer/Password.set("custom_colors/font_color",Color(1.0,0.5,0.5))
		else:
			$VBoxContainer/MarginContainer/VBoxContainer/Password.set("custom_colors/font_color",Color(1.0,1.0,1.0))
		if login.length()<5:
			$VBoxContainer/MarginContainer/VBoxContainer/Login.set("custom_colors/font_color",Color(1.0,0.5,0.5))
		else:
			$VBoxContainer/MarginContainer/VBoxContainer/Login.set("custom_colors/font_color",Color(1.0,1.0,1.0))

func _process(delta):
	
	if form_completed and SessionManager.is_logedin():
		$Tween.translate(Vector2(),Vector2(-get_viewport_rect().size.x,0))
		User.update_data()
		form_completed = false
	else:
		if form_visible == false and form_completed == false:
			$AnimationPlayer.play_backwards("fade")
		if SessionManager.error != SessionManager.ERROR.NONE:
			form_completed = false
			SessionManager.clear_error()
			$VBoxContainer/MarginContainer/VBoxContainer/Password.set("custom_colors/font_color",Color(1.0,0.5,0.5))
			$VBoxContainer/MarginContainer/VBoxContainer/Login.set("custom_colors/font_color",Color(1.0,0.5,0.5))

func _on_TextureButton_pressed():
	if $host.visible :
		$host.visible = false
	else:
		$host.visible = true
	$host.rect_min_size = Vector2(get_viewport_rect().size.x-225,0)
	$host.text = SessionManager.domian

func _on_LineEdit_text_changed(new_text):
	SessionManager.domian = new_text
