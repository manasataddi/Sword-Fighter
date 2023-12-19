extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var enemies_group = get_node("Enemies")
	for enemy in enemies_group.get_children():
		enemy.hide_enemy()
		
	restart()
	
func game_over():
	$HUD.game_over()
	$HUD.layer = 2

func restart():
	$Player.hide()
	$HUD.show()
	$HUD.layer = 2

func _on_Area2D_body_entered(body):
	if body is KinematicBody2D:
		$Player.position = Vector2.ZERO

func game_init():
	$Player.show()
	$Player.reset_player()

	# enemies
	var enemies_group = get_node("Enemies")
	for enemy in enemies_group.get_children():
		enemy.show_enemy()

func _on_HUD_start_game():
	game_init()
	$HUD.layer = -10

func _on_Player_enemy_collided():
	$Player.position = Vector2.ZERO

func _on_Flag_body_entered(body):
	if body is KinematicBody2D:
		print(body)
		$HUD.win()
		$HUD.show()
		$HUD.layer = 2
