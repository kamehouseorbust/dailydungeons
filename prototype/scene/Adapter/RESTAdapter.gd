extends Node

# This scene currently uses mocked data, use mocky.io and the json "{"seed":xxxxxx}" for the body to mock.
# Then modify the url variable.

onready var _ref_GameData = get_node("/root/GameData")

# mocked endpoint
var url = "https://run.mocky.io/v3/65bd6c14-6d7b-4acd-a4e2-df39113b1ca0"

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
