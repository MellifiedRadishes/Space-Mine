extends Sprite2D
class_name Player
@export var planet : Planet
@export var coalText : RichTextLabel
@export var ironText : RichTextLabel
@export var moneyText : RichTextLabel
@export var fuelText : RichTextLabel
@export var sellOreButton : Button
@export var sellCoalButton : Button
@export var refuelButton : Button
@export var buyMenuButton : Button

@export var speedUpgradeButton: Button
@export var miningSpeedUpgradeButton: Button
@export var refuelPurchaseButton: Button

var xPos = 0
var yPos = 0
var mineSpeed = 1
var money = 0;
var isBuyMenuOpen : bool

var fuel = 300;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	planet._instantiate();
	planet._clearTile(xPos, yPos);
	planet._printOut();
	_fixPosition();
	sellOreButton.pressed.connect(self._sellIron);
	sellCoalButton.pressed.connect(self._sellCoal);
	refuelButton.pressed.connect(self._refuel);
	
	# Buy Menu Functionality
	buyMenuButton.pressed.connect(self._buyMenuToggle)
	miningSpeedUpgradeButton.pressed.connect(self._buyMiningUpgrade)
	speedUpgradeButton.pressed.connect(self._buySpeedUpgrade)
	refuelPurchaseButton.pressed.connect(self._buyFuel)
	for child in buyMenuButton.get_children():
		child.visible = false
	pass # Replace with function body.

var waitTime : float = .1
var waiting : bool = false;
func _startWaiting() -> void:
	waiting = true;
	await get_tree().create_timer(waitTime).timeout
	waiting = false;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waiting or isBuyMenuOpen:
		return
	
	if (Input.is_key_pressed(KEY_W)):
		if (_move(0, -1)):
			yPos -= 1;
		rotation_degrees = 270;
		planet._printOut();
		_fixPosition();
		_startWaiting();
	elif (Input.is_key_pressed(KEY_S)):
		if (_move(0, 1)):
			yPos += 1;
		rotation_degrees = 90;
		planet._printOut();
		_fixPosition();
		_startWaiting();
	elif (Input.is_key_pressed(KEY_A)):
		if (_move(-1, 0)):
			xPos -= 1;
		rotation_degrees = 180;
		planet._printOut();	
		_fixPosition();
		_startWaiting();
	elif (Input.is_key_pressed(KEY_D)):
		if (_move(1, 0)):
			xPos += 1;
		rotation_degrees = 0;
		planet._printOut();
		_fixPosition();
		_startWaiting();
	pass

func _mine(tile : Tile) -> Tile.BlockType:
	return tile._reduceHP(mineSpeed);
	
func _move(xDel : int, yDel : int) -> bool:
	if (fuel == 0):
		var gameOver = preload("res://GameOver.tscn").instantiate();
		gameOver.moneyText.text = "[center]You made $" + str(money) + "\n\nAnd you only have to stay in the inky black void forever!";
		get_parent().add_child(gameOver);
		
		return false;
	
	fuel -= 1;
	match planet._checkMove(xPos + xDel, yPos + yDel):
		Planet.MoveResponse.OUTOFBOUNDS:
			return false;
		
		Planet.MoveResponse.HITTILE:
			var type = _mine(planet._getTile(xPos + xDel, yPos + yDel));
			if (type != Tile.BlockType.NONE):
				_increaseBlocks(type)
				planet._clearTile(xPos + xDel, yPos + yDel);
				return true;
			return false;
			
		Planet.MoveResponse.OPEN:
			return true;
			
		_:
			#Just in case it falls through
			return false;
	
var blockDict = {Tile.BlockType.DIRT : 0, Tile.BlockType.COAL : 0, Tile.BlockType.IRON : 0}
func _increaseBlocks(type : Tile.BlockType) -> void:
	blockDict[type] += 1;
	
func _fixPosition() -> void:
	position = Vector2(xPos * 32 + 16, yPos * 32 + 16);
	coalText.text = "Coal: " + str(blockDict[Tile.BlockType.COAL]);
	ironText.text = "Ore: " + str(blockDict[Tile.BlockType.IRON]);
	moneyText.text = "$" + str(money);
	fuelText.text = "Fuel: " + str(fuel);
	return;
	
func _sellIron():
	if (blockDict[Tile.BlockType.IRON] == 0):
		return;
		
	blockDict[Tile.BlockType.IRON] -= 1;
	money += 100;
	_fixPosition();
	return;
		
func _sellCoal():
	if (blockDict[Tile.BlockType.COAL] == 0):
		return;
	
	blockDict[Tile.BlockType.COAL] -= 1;
	money += 75;
	_fixPosition();
	return;
	
func _refuel():
	if (blockDict[Tile.BlockType.COAL] == 0):
		return;
	
	var refuelAmount = 300 - fuel;
	refuelAmount /= 5;
	refuelAmount = int(refuelAmount);
	if (blockDict[Tile.BlockType.COAL] < refuelAmount):
		refuelAmount = blockDict[Tile.BlockType.COAL];
	
	print("refueling " + str(refuelAmount));
		
	blockDict[Tile.BlockType.COAL] -= refuelAmount;
	fuel += refuelAmount * 5;
	_fixPosition();
	return;

func _buyMenuToggle():
	if not isBuyMenuOpen:
		isBuyMenuOpen = true
		
		for child in buyMenuButton.get_children():
			child.visible = true
		
	else:
		isBuyMenuOpen = false
		
		for child in buyMenuButton.get_children():
			child.visible = false

func _buyMiningUpgrade():
	if money >= 1000:
		money -= 1000
		mineSpeed *= 1.5
		_fixPosition()
		
func _buySpeedUpgrade():
	if money >= 250:
		money -= 250
		waitTime *= 0.95
		_fixPosition()

func _buyFuel():
	if money >= 2000 and fuel != 300:
		money -= 2000
		fuel = 300
		_fixPosition()
