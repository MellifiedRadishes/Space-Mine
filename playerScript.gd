extends Sprite2D
class_name Player
@export var planet : Planet
@export var coalText : RichTextLabel
@export var ironText : RichTextLabel
@export var moneyText : RichTextLabel
@export var quotaText : RichTextLabel
@export var dialogueText : RichTextLabel
@export var fuelBar : TextureProgressBar
@export var sellOreButton : Button
@export var sellCoalButton : Button
@export var refuelButton : Button
@export var buyMenuButton : Button

@export var speedUpgradeButton: Button
@export var miningSpeedUpgradeButton: Button
@export var refuelPurchaseButton: Button
@export var contactCompanyButton: Button
@export var closeTransmissionButton: Button

var xPos = 0
var yPos = 0
var quota = 800
var quotaType = 0
var quotaTier = 0
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
	
	#Dialouge Functionality
	contactCompanyButton.pressed.connect(self._openTransmission)
	closeTransmissionButton.pressed.connect(self._closeTransmission)
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
	fuelBar.value = fuel;
	return;
	
func _sellIron():
	if (blockDict[Tile.BlockType.IRON] == 0):
		return;
		
	money += 100 * blockDict[Tile.BlockType.IRON];
	blockDict[Tile.BlockType.IRON] = 0;
	_fixPosition();
	return;
		
func _sellCoal():
	if (blockDict[Tile.BlockType.COAL] == 0):
		return;
	
	money += 25 * blockDict[Tile.BlockType.COAL];
	blockDict[Tile.BlockType.COAL] = 0;
	_fixPosition();
	return;
	
func _refuel():
	if (blockDict[Tile.BlockType.COAL] == 0):
		return;
	
	var refuelAmount = 300 - fuel;
	refuelAmount /= 3;
	refuelAmount = int(refuelAmount);
	if (blockDict[Tile.BlockType.COAL] < refuelAmount):
		refuelAmount = blockDict[Tile.BlockType.COAL];
		
	blockDict[Tile.BlockType.COAL] -= refuelAmount;
	fuel += refuelAmount * 3;
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
		
func _openTransmission():
	if (_checkQuota()):
		if (quotaTier == 0):
			dialogueText.text = "Good job on completing your first quota, that was just a small introductory task to get you started, the work is only going to get harder from here. Next we're going to need a shipment of raw ore back to headquarters. Send us 20 ore pronto."
			quota = 20
			quotaType = 1
			quotaText.text = "Quota: 20 Ore"
		elif (quotaTier == 1):
			dialogueText.text = "Another quota down, you're making good progress recruit, another sector is running low on fuel reserves we're going to need a shipment from you. Send 15 Coal our way as soon as you can we need to get that other operation back online."
			quota = 15
			quotaType = 2
			quotaText.text = "Quota: 15 Coal"
		elif (quotaTier == 2):
			dialogueText.text = "You're starting to get the hang of it, lets see you get out there and make some real money for the company. Show us you're worth the investment and bring in $10,000 as soon as possible"
			quota = 10000
			quotaType = 0
			quotaText.text = "Quota: $10k"
		elif (quotaTier == 3):
			dialogueText.text = "Good work but you'll need to keep it up if you want to impress anyone in this industry, so far you've met the expectations of the bare minumum, we want to see more profit which means you need to get back to stripping these rocks bare and double time it, lets see $20,000 this time."
			quota = 20000
			quotaType = 0
			quotaText.text = "Quota: $20k"
		elif (quotaTier == 4):
			dialogueText.text = "You're going to need to be effecient with your fuel for a bit, management needs coal and a lot of it. Don't ask what its for just pull it from the ground and ship it over, 150 units minumum."
			quota = 150
			quotaType = 2
			quotaText.text = "Quota: 150 Coal"
		elif (quotaTier == 5):
			dialogueText.text = "Looks like somebody's getting the hang of this, time for you to shoot for the big leagues. If you want to do that the name of the game is profit, profit, profit. If you can bring in $40,000 maybe you've got a shot a promotion. Not likely but you should give it a shot anyway, not like you have a choice."
			quota = 40000
			quotaType = 0
			quotaText.text = "Quota: $40k"
		elif (quotaTier == 6):
			dialogueText.text = "Good going, rookie. Well not so much of a rookie anymore are you? Well then big shot heres a task straight from upper management, resale of ore is tripled 3 sectors over so its up to you to bring in the motherlode. 400 ore should do the trick."
			quota = 400
			quotaType = 1
			quotaText.text = "Quota: 400 Ore"
		elif (quotaTier == 7):
			dialogueText.text = "Alright one more job, simple and straighforward we just need $100,000 out of you. This is the big one, if you can bring in that kind of cash upper managment will take note for sure and I bet there'll be a bright future in store for you."
			quota = 100000
			quotaType = 0
			quotaText.text = "Quota: $100k"
		elif (quotaTier == 8):
			dialogueText.text = "Wow you really did it, good job kid. Unfortunately our bottom line still needs you, don't come back until you've met the new profit margins."
			quota = 10000000
			quotaType = 1
			quotaText.text = "Quota: $10M"
		else:
			dialogueText.text = "You weren't supposed to be able to get this far so idk how you're seeing this."
		quotaTier = quotaTier + 1
	else :
		dialogueText.text = "You still got a ways to go to meet your quota, get back to work and make it snappy!"
	_fixPosition()
	for child in contactCompanyButton.get_children():
		child.visible = true

func _closeTransmission():
	for child in contactCompanyButton.get_children():
		child.visible = false

func _checkQuota() -> bool:
	if (quotaType == 0):
		if (money >= quota):
			money -= quota
			_fixPosition()
			return true
	elif (quotaType == 1):
		if (blockDict[Tile.BlockType.IRON] >= quota):
			blockDict[Tile.BlockType.IRON] -= quota
			_fixPosition()
			return true
	elif (quotaType == 2):
		if (blockDict[Tile.BlockType.COAL] >= quota):
			blockDict[Tile.BlockType.COAL] -= quota
			_fixPosition()
			return true
	return false
