extends Node2D


signal sprite_created(new_sprite)

const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Floor := preload("res://sprite/Floor.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var _ref_DungeonBoard: DungeonBoard

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()

onready var _ref_walker = get_node("/root/Walker")
onready var _ref_GameData = get_node("/root/GameData")

var _rng := RandomNumberGenerator.new()

# we add -2 here so that the ring of walls around the dungeon is intact
var borders = Rect2(1, 1, _new_DungeonSize.MAX_X-2, _new_DungeonSize.MAX_Y-2)

func _ready() -> void:
	#_rng.randomize()
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputName.INIT_WORLD):
		# need a reliable way to wait for the seed to be given via API before init
		seed(_ref_GameData._seed)
		_rng.seed = _ref_GameData._seed
		_init_floor()
		_init_wall()
		_init_PC()
		_init_dwarf()
		_init_indicator()

		set_process_unhandled_input(false)

func generate_level():
	var x: int = _rng.randi_range(1, _new_DungeonSize.MAX_X - 1)
	var y: int = _rng.randi_range(1, _new_DungeonSize.MAX_Y - 1)
	_ref_walker.new_level(Vector2(x,y), borders)
	var map = _ref_walker.walk(_new_DungeonSize.WALKER_STEPS)
	return map


func _init_dwarf() -> void:
	var dwarf: int = _rng.randi_range(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _rng.randi_range(1, _new_DungeonSize.MAX_X - 1)
		y = _rng.randi_range(1, _new_DungeonSize.MAX_Y - 1)
		
		if _ref_DungeonBoard.has_sprite(_new_GroupName.WALL, x, y) \
				or _ref_DungeonBoard.has_sprite(_new_GroupName.DWARF, x, y):
			continue
		_create_sprite(Dwarf, _new_GroupName.DWARF, x, y)
		dwarf -= 1


func _init_PC() -> void:
	#create player at start of walker
	_create_sprite(Player, _new_GroupName.PC, _ref_walker.step_history[0].x,  _ref_walker.step_history[0].y)


func _init_floor() -> void:
	var floorspaces = generate_level()
	for location in floorspaces:
		_create_sprite(Floor, _new_GroupName.FLOOR, location.x, location.y)


func _init_wall() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if !_ref_DungeonBoard.has_sprite(_new_GroupName.FLOOR, i, j):
				_create_sprite(Wall, _new_GroupName.WALL, i, j)


func _init_indicator() -> void:
	_create_sprite(ArrowX, _new_GroupName.ARROW, 0, 12,
			-_new_DungeonSize.ARROW_MARGIN)
	_create_sprite(ArrowY, _new_GroupName.ARROW, 5, 0,
			0, -_new_DungeonSize.ARROW_MARGIN)


func _create_sprite(prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> void:

	var new_sprite: Sprite = prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(group)

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite)
