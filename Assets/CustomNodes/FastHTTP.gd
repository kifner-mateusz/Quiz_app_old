extends Object
class_name FastHTTP

export var host = "http://mk.ssa.iq.pl"
export var game_location = "/Admin/tictactoe"
export var game_lobby = "/Admin/lobby"
export var log_out = "/Admin/log_out"
export var suffix = ".php"

var http = HTTPClient.new() # Create the Client.
var err = 0
var cookies = ""

func _ready():
	print(send(log_out)[0])

func host_connect() -> bool:
	err = http.connect_to_host(host, 80) # Connect to host/port.
	if(err != OK):
		return false
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()

	if(http.get_status() == HTTPClient.STATUS_CONNECTED):
		return true
	else:
		return false

func send(location:String, message:PoolByteArray = [0]) -> PoolByteArray:
	if(host_connect()):
		var headers = ["User-Agent: Pirulo/1.0 (Godot)", "Accept: */*","Cookie: %s" % cookies]
		if(message[0]):
			var fields = {0:""}
			for i in range(message.size()):
				fields[0] += "%02X" % message[i]
			var query_string = http.query_string_from_dict(fields)
			var message_headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
			headers.append(message_headers[0])
			headers.append(message_headers[1])
			err = http.request(HTTPClient.METHOD_POST, location + suffix, headers, query_string) 
		else:
			err = http.request(HTTPClient.METHOD_GET, location + suffix, headers)
		if(err != OK):
			return PoolByteArray([0])
		
		while http.get_status() == HTTPClient.STATUS_REQUESTING:
			http.poll()
	
		if!(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED):
			return PoolByteArray([0])
		
		if http.has_response():
			headers = http.get_response_headers_as_dictionary()
			if( ("Set-Cookie" in headers) and cookies.empty()):
				for h in headers:
					if h.to_lower().begins_with("set-cookie"):
						cookies = headers[h]
			var bytes = PoolByteArray()

			while http.get_status() == HTTPClient.STATUS_BODY:
				http.poll()
				var chunk = http.read_response_body_chunk()
				if chunk.size() != 0:
					bytes = bytes + chunk
			if(bytes.size() > 0):
				return bytes
	return PoolByteArray([0])
	
func send_push(location:String,message:PoolByteArray,push:Dictionary) -> String:
	if(host_connect()):
		var headers = ["User-Agent: Pirulo/1.0 (Godot)", "Accept: */*","Cookie: %s" % cookies]
		if(message.size() > 0 and push.size() > 0):
			var fields = {0:""}
			for i in range(message.size()):
				fields[0] += "%02X" % message[i]
			for key in push.keys():
				fields[key] = push[key]
			var query_string = http.query_string_from_dict(fields)
			var message_headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(query_string.length())]
			headers.append(message_headers[0])
			headers.append(message_headers[1])
			print(query_string)
			err = http.request(HTTPClient.METHOD_POST, location + suffix, headers, query_string) 
		else:
			err = http.request(HTTPClient.METHOD_GET, location + suffix, headers)
		if(err != OK):
			return ""
		
		while http.get_status() == HTTPClient.STATUS_REQUESTING:
			http.poll()
	
		if!(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED):
			return ""
		
		if http.has_response():
			headers = http.get_response_headers_as_dictionary()
			if( ("Set-Cookie" in headers) and cookies.empty()):
				for h in headers:
					if h.to_lower().begins_with("set-cookie"):
						cookies = headers[h]
			var bytes = PoolByteArray()

			while http.get_status() == HTTPClient.STATUS_BODY:
				http.poll()
				var chunk = http.read_response_body_chunk()
				if chunk.size() != 0:
					bytes = bytes + chunk
			if(bytes.size() > 0):
				return bytes.get_string_from_ascii()
	return ""
