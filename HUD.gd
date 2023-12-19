extends CanvasLayer

signal start_game

var background_group

func _ready():
	background_group = get_node("Background")
	for node in background_group.get_children():
		node.show()
		
	show_info()
	
func hide_info():
	$StartButton.hide()
	$Title.hide()
	$Instruction.hide()
	$Win.hide()
	
func show_info():
	$StartButton.show()
	$Title.show()
	$Instruction.show()
	
func win():
	$StartButton.show()
	$Title.hide()
	$Instruction.hide()
	$Win.show()
	
func start_game():
	hide_info()
	emit_signal("start_game")

func _on_Button_pressed():
	start_game()

func game_over():
	show_info()
