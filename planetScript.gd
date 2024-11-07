extends TileMapLayer

class_name Planet
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var tileData : Array[Tile] = [];
var xSize : int = 30;
var ySize : int = 30;

func _instantiate() -> bool:
	randomize();
	tileData.resize(xSize * ySize)
	for x in xSize:
		for y in ySize:
			tileData[x + y * xSize] = Tile.new();
			tileData[x + y * xSize].hp = randi() % 3 + 4;
			tileData[x + y * xSize].blockType = Tile.BlockType.DIRT;
			#set_cell(coords : Vector2i(x, y), source_id : int = 0, atlas_Coords : Vector2i = tileArray[x, y * xSize], alternate_Tile : 0);
	return true;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


enum MoveResponse { OUTOFBOUNDS, HITTILE, OPEN }
func _checkMove(x : int, y: int) -> MoveResponse:
	if (x < 0 || y < 0 || x >= xSize || y >= ySize):
		return MoveResponse.OUTOFBOUNDS;
	if (_getTile(x, y) == null):
		return MoveResponse.OPEN;
	return MoveResponse.HITTILE;
	
func _getTile(x : int, y : int) -> Tile:
	if (x < 0 || y < 0 || x >= xSize || y >= ySize):
		return null;
	return tileData[x + y * xSize];
	
func _clearTile(x : int, y : int) -> void:
	if (_getTile(x, y) == null):
		return;
	tileData[x + y * xSize] = null;
	
func _printOut(playerX : int, playerY : int, fuel: int, blocks : int) -> void:
	print("");
	for y in ySize:
		var line : String = "";
		for x in xSize:
			if (playerX == x && playerY == y):
				line += "<> ";
			else:
				if (_getTile(x, y) == null):
					line += "   ";
					continue;
				line += " " + str(_getTile(x, y).hp) + " ";
		
		if (y == 0):
			line += "   fuel: " + str(fuel);
			
		if (y == 1):
			line += "  mined: " + str(blocks);
		print(line)
			
