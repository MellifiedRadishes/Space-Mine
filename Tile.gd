extends Sprite2D
class_name Tile
var hp : int = 3;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

enum BlockType {NONE, DIRT, COAL, IRON}

var blockType;
func _reduceHP(dmg : int) -> BlockType:
	hp -= dmg;
	if (hp <= 0):
		return blockType;
	return BlockType.NONE;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
