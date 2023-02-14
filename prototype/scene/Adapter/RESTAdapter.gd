extends Node

onready var _ref_GameData = get_node("/root/GameData")

# aws endpoint
var url = "https://xiexdtcndc.execute-api.us-west-2.amazonaws.com/getdailyseed"

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(body.size() != 0):
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result)
		_ref_GameData._seed = json.result.seed
	else :
		_ref_GameData._seed = 1234567
