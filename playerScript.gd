extends AnimatedSprite2D
class_name Player
@export var tileMapPath : NodePath
@export var planet : Planet
@onready var tileMap = get_node_or_null(tileMapPath)


var xPos = 0
var yPos = 0
var mineSpeed = 1

var fuel = 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	planet._instantiate();
	planet._clearTile(xPos, yPos);
	pass # Replace with function body.

var waitTime : float = .3
var waiting : bool = false;
func _startWaiting() -> void:
	waiting = true;
	await get_tree().create_timer(waitTime).timeout
	waiting = false;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (waiting):
		return
	
	if (Input.is_key_pressed(KEY_W)):
		if (_move(0, -1)):
			yPos -= 1
		planet._printOut(xPos, yPos, fuel);
		_startWaiting();
	elif (Input.is_key_pressed(KEY_S)):
		if (_move(0, 1)):
			yPos += 1;
		planet._printOut(xPos, yPos, fuel);
		_startWaiting();
	elif (Input.is_key_pressed(KEY_A)):
		if (_move(-1, 0)):
			xPos -= 1;
		planet._printOut(xPos, yPos, fuel);	
		_startWaiting();
	elif (Input.is_key_pressed(KEY_D)):
		if (_move(1, 0)):
			xPos += 1;
		planet._printOut(xPos, yPos, fuel);
		_startWaiting();
	pass

func _mine(tile : Tile) -> bool:
	return tile._reduceHP(mineSpeed);
	
func _move(xDel : int, yDel : int) -> bool:
	if (fuel == 0):
		return false;
	
	fuel -= 1;
	match planet._checkMove(xPos + xDel, yPos + yDel):
		Planet.MoveResponse.OUTOFBOUNDS:
			return false;
		
		Planet.MoveResponse.HITTILE:
			if (_mine(planet._getTile(xPos + xDel, yPos + yDel))):
				planet._clearTile(xPos + xDel, yPos + yDel);
				return true;
			return false;
			
		Planet.MoveResponse.OPEN:
			return true;
			
		_:
			#Just in case it falls through
			return false;
		
	
