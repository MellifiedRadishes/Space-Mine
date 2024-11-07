extends Sprite2D
class_name Tile
var hp : int = 3;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _reduceHP(dmg : int) -> bool:
	hp -= dmg;
	if (hp <= 0):
		return true;
	return false;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
