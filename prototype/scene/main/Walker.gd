extends Node

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []
var steps_since_turn = 0

func new_level(starting_position, new_borders):
	step_history = []
	steps_since_turn = 0
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders


func walk(steps):
	create_room()
	for step in steps:
		if steps_since_turn >= 5:
			change_direction()
		if step():
			step_history.append(position)
		else:
			change_direction()
	return step_history


func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		return true
	else:
		return false


func change_direction():
	create_room()
	steps_since_turn = 0
	# pick a random direction up, down, left, right
	var directions = DIRECTIONS.duplicate()
	directions.erase(DIRECTIONS)
	directions.shuffle()
	direction = directions.pop_front()
	# if the direction is not in bounds, get the next one
	while not borders.has_point(position + direction):
		direction = directions.pop_front()


func create_room():
	# create a room of random size x = 2 to 4 and y = 2 to 4
	var size = Vector2(randi() % 4 + 2, randi() % 4 + 2)
	var top_left_corner = (position - size/2).ceil()
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x,y)
			if(borders.has_point(new_step)):
				step_history.append(new_step)
