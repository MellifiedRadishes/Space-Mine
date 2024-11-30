extends Node2D

class_name Planet
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var tileData : Array[Tile] = [];
var xSize : int = 60;
var ySize : int = 40;

@export var tileScene : PackedScene;
@export var dirtTileSprites : Array[Texture2D];
@export var ironTileSprites : Array[Texture2D];
@export var coalTileSprites : Array[Texture2D];

func _instantiate() -> bool:
	dirtTileSprites = [load("res://DirtTile1.png"), load("res://DirtTile2.png"), load("res://DirtTile3.png")];
	ironTileSprites = [load("res://IronTile1.png"), load("res://IronTile2.png"), load("res://IronTile3.png"), load("res://IronTile4.png")];
	coalTileSprites = [load("res://CoalTile1.png"), load("res://CoalTile2.png"), load("res://CoalTile3.png"), load("res://CoalTile4.png"), load("res://CoalTile5.png")];
	randomize();
	tileData.resize(xSize * ySize)
	for x in xSize:
		for y in ySize:
			tileData[x + y * xSize] = tileScene.instantiate();
			add_child(tileData[x + y * xSize]);
			tileData[x + y * xSize].position = Vector2(x * 32 + 16, y * 32 + 16);
			var hp = randi() % 3 + 3;
			tileData[x + y * xSize].hp = hp;
				
			if (hp == 3):
				tileData[x + y * xSize].blockType = Tile.BlockType.DIRT;
			
			if (hp == 4):
				tileData[x + y * xSize].blockType = Tile.BlockType.COAL;
				
			if (hp == 5):
				tileData[x + y * xSize].blockType = Tile.BlockType.IRON;
			
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
	_getTile(x, y).queue_free();
	tileData[x + y * xSize] = null;
	
func _printOut(playerX : int, playerY : int, fuel: int, blocks : int) -> void:
	for y in ySize:
		for x in xSize:
			if (_getTile(x, y) == null):
				continue;
				
			match(_getTile(x, y).BlockType):
				Tile.BlockType.DIRT:
					_getTile(x, y).texture = dirtTileSprites[3 - _getTile(x, y).hp];
				
				Tile.BlockType.IRON:
					_getTile(x, y).texture = ironTileSprites[4 - _getTile(x, y).hp];
					
				Tile.BlockType.COAL:
					_getTile(x, y).texture = coalTileSprites[5 - _getTile(x, y).hp];
					
