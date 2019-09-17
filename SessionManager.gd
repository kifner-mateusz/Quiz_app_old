extends HTTPRequest

export var token:String = ""
export var token2:String = ""
export var domian = "http://mk.ssa.iq.pl/Quiz_webapp/"
export var use_ssl = false

var cookies:String = ""
var processing_request = false
var org_domian = "http://mk.ssa.iq.pl/Quiz_webapp/"
var count = 0
var queue = []

enum RESPONSE{
	NONE = 0,
	LOGIN = 1,
	LOGOUT = 2,
	PING = 3,
	USER_DATA = 4,
	PUZZLE_LIST = 5,
	PUZZLE_DATA = 6,
	QUIZ_DATA = 7,
	PUZZLE_STATUS = 8,
	USER_GRADES = 9,
	PUZZLE_ANS =10,
	REQUEST_SUCCESSFUL = 200,
	SESSION_DESTROY = 5,
	UNUSED = 124,
	ERROR_TOKEN_NOT_SET = 240,
	ERROR_PUZZLE = 241,
	ERROR_DATA_IS_MISSING = 242
}

enum ERROR{
	NONE = 0,
	LOGIN = 1,
	CONNECTION = 2,
	DATA = 3,
	PROCESSING = 3
}

var error = ERROR.NONE

func _ready():
	use_threads = true
	connect("request_completed",self,"_request_completed")
	load_tokens()

func login(login,password):
	_request("login.php",{"login":login,"password":password})

func logout():
	token = ""
	token2 = ""
	save_tokens()
	get_tree().reload_current_scene()
	
func session_destroy():
	_request("logout.php")

func is_logedin():
	if(token != "" and token2 != ""):
		return true
	else:
		return false

func ping():
	_request("ping.php")
	
func clear_error():
	error = ERROR.NONE
	
func get_data(data_type):
	_request("get_data.php",{"data":data_type})
	

	
func _process(delta):
	if(not(processing_request) and queue.size()>0):
		var req = queue.pop_front()
		callv(req["function"],req["args"])

func _request(url:String,post_dict:Dictionary = Dictionary()):
	if not(processing_request):
		processing_request = true
		print("REQUEST SEND")
		var query = ""
		var method = HTTPClient.METHOD_POST
		if(domian.length()==0):
			domian = org_domian
		var cookie_header
		if is_logedin():
			cookie_header = "Cookie: %s;token=%s" % [cookies,token]
		else:
			cookie_header = "Cookie: %s" % cookies
		var headers = ["User-Agent: Pirulo/1.0 (Godot)", "Accept: */*",cookie_header]
		if not(post_dict.empty()):
			query = HTTPClient.new().query_string_from_dict(post_dict)
		if is_logedin():
			var control;
			
	#		print(token + query, " | count = ", count)
			if(query.length()>0):
				query += "&hash=" + secure_hash(token + query)
			else:
				query += "hash=" + secure_hash(token + query)
		var message_headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query.length())]
		headers.append(message_headers[0])
		headers.append(message_headers[1])
	
#		print(query,"\n",headers)
		request(domian+url, headers, use_ssl, method, query)
	else:
		error = ERROR.PROCESSING
		print("ERROR: still processing")
	


func _request_completed(result, response_code, headers, body):
	print("REQUEST RECIVED")
	processing_request = false
	if response_code != 200:
		error = ERROR.CONNECTION
		return
	if( cookies.empty()):
		for h in headers:
			if h.to_lower().begins_with("set-cookie"):
#				print(h.split(":")[1])
				cookies = h.split(":")[1]
	if(body.size() > 1):
		count = (body[1] + 1) % 256
		print( response_code, " : ",body[0]," ",body[1], ":", body.get_string_from_ascii().substr(0,300)+ "[...]" )
		match body[0]:
			RESPONSE.LOGIN:
				body[0]=48
				body[1]=48
				var json = JSON.parse(body.get_string_from_ascii().split("|")[1]).result
				if json is Dictionary and not(json.empty()):
					error = ERROR.NONE
					for res in json.keys():
						if(res == "token"):
							token = json[res]
						if(res == "token2"):
							token2 = json[res]
#						print(res, " : ", json[res])
						if OS.is_debug_build():
							get_node("/root/Main/Debug/Control/Label").text += res+ " : "+json[res] + "\n"
					save_tokens()
#					User.update_data()
				else:
					error = ERROR.LOGIN
					print("Login Error")
				print("Response login")
			RESPONSE.USER_DATA:
				if(pharse_data_to_dict(body,User.user_data)):
					User.user_data_is_set()
			RESPONSE.PUZZLE_DATA:
				if(pharse_data_to_dict(body,Puzzle.current_puzzle_data)):
					Puzzle.current_puzzle_data_is_set()
			RESPONSE.PUZZLE_ANS:
				if(pharse_data_to_dict(body,Puzzle.current_puzzle_ans)):
					Puzzle.current_puzzle_ans_is_set()
			RESPONSE.PUZZLE_LIST:
				if(pharse_data_to_array(body,Puzzle.puzzle_list)):
					Puzzle.puzzle_list_is_set()
			RESPONSE.PUZZLE_STATUS:
				if(pharse_data_to_dict(body,Puzzle.puzzle_status_data)):
					Puzzle.puzzle_status_data_is_set()
			RESPONSE.USER_GRADES:
				if(pharse_data_to_dict(body,User.user_grades_data)):
					User.user_grades_data_is_set()
			RESPONSE.ERROR_TOKEN_NOT_SET:
				print("SERVER : TOKENS NOT SET")
				logout()
#				session_destroy()
			RESPONSE.LOGOUT:
				print("SERVER : LOGOUT")
				logout()
	
func load_tokens():
#	TODO: add encription
	var token_file = ConfigFile.new()
	if token_file.load("user://tokens.data") == OK:
		token = token_file.get_value("tokens","token","")
		token2 = token_file.get_value("tokens","token2","")
		if(token_file.get_value("tokens","Admin","false") == "false"):
			User.admin_enable = false
		else:
			User.admin_enable = true
			
	else:
		save_tokens()

func save_tokens():
	var token_file = ConfigFile.new()
	token_file.set_value("tokens","token",token)
	token_file.set_value("tokens","token2",token2)
	if(User.admin_enable):
		token_file.set_value("tokens","Admin","true")
	else:
		token_file.set_value("tokens","Admin","false")
		
	token_file.save("user://tokens.data")

func secure_hash(message):
	var token2_len:int = token2.length()
	var start_pos:float = float(hex2int(token2.substr(0,4))+count)/(hex2int(token2.substr(4,4))+256)
	var start_pos2:float = float(hex2int(token2.substr(8,4))+count)/(hex2int(token2.substr(12,4))+256)
	var start_pos_str = "%08d" % (start_pos*100000000)
	var start_pos2_str = "%08d" % (start_pos2*100000000)
	start_pos_str = start_pos_str.substr(2,4)
	start_pos2_str = start_pos2_str.substr(2,4)
	var pos = int(start_pos_str) % token2_len
	var pos2 = int(start_pos2_str) % token2_len
	var new_message = message
	for i in range(message.length()):
		var step:int = hex2int(token2.substr(pos,1))
		if(message.ord_at(i) + step>126):
			step-=20
		new_message[i] = message.ord_at(i) + step
		pos = (pos + pos2) % token2_len
	return new_message.sha256_text()
	

func hex2int(hex:String) -> int:
	var result:int = 0
	var hex_length:int = hex.length()
	for i in range(hex_length):
		var char_code = hex.ord_at(i)
		if(char_code > 96):
			char_code -= 32
		if(char_code > 64):
			char_code -= 55
		else:
			char_code -= 48
		result += char_code * pow(16,hex_length-i-1)
	return result
	
func pharse_data_to_dict(body,dict):
	body[0]=48
	body[1]=48
	var json = JSON.parse(body.get_string_from_utf8().split("|")[1]).result
	if json is Dictionary and not(json.empty()):
		error = ERROR.NONE
		for res in json.keys():
#			print(res, " : ", json[res])
			dict[res] = json[res]
		return true
	else:
		error = ERROR.DATA
		print("DATA ERROR")
		return false

func pharse_data_to_array(body,array):
	body[0]=48
	body[1]=48
	var json = JSON.parse(body.get_string_from_utf8().split("|")[1]).result
#	print("json : ",json)
	if json is Array and not(json.empty()):
		error = ERROR.NONE
		for i in json:
			array.append(i)
		return true
	else:
		error = ERROR.DATA
		print("DATA ERROR")
		return false
		
func add_to_queue(function,args):
	queue.append({"function":function,"args":args})