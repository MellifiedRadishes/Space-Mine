extends TextureRect

@export var moneyText : RichTextLabel;
@export var button : TextureButton;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(self._load_main);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _load_main():
	get_tree().change_scene_to_file("res://main_menu.tscn");
