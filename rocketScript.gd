extends Sprite2D
class_name Rocket

@export var collision_area : Area2D
@export var collision_shape : CollisionShape2D
@export var enter_planet_buton: Button

signal enter
signal exit

var velocity = Vector2(0,0)
var acceleration = .75
var braking = .5
var rotational_speed = 1
var thrust = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	enter_planet_buton.visible = false
	enter_planet_buton.pressed.connect(_enter_planet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_key_pressed(KEY_W):
		thrust += Vector2(cos(rotation), sin(rotation)) * -acceleration 
	
	if Input.is_key_pressed(KEY_S):
		if thrust.x > 0.0:
			thrust.x -= braking
		else:
			thrust.x += braking
			
		if thrust.y > 0.0:
			thrust.y -= braking
		else:
			thrust.y += braking

	if Input.is_key_pressed(KEY_A):
		rotation -= rotational_speed * delta
		
	if Input.is_key_pressed(KEY_D):
		rotation += rotational_speed * delta
	
	velocity = thrust * delta
	position = position + velocity

func _on_area_2d_area_entered(area):
	enter_planet_buton.visible = true

func _on_area_2d_area_exited(area):
	enter_planet_buton.visible = false

func _enter_planet():
	get_tree().change_scene_to_file("res://DemoScene.tscn")
