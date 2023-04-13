extends CanvasLayer

enum MenuState { OPEN, CLOSED }

@onready var dialogue_menu = $Control
@onready var anim_player = $Control/NinePatchRect/AnimationPlayer

var menu_state = null


func _ready():
	close_menu()


func _unhandled_input(event):
	if event.is_action_pressed("main_action"):
		if menu_state == MenuState.CLOSED:
			open_menu()
		else:
			close_menu()


func open_menu():
	GlobalSettings.stop_movement = true
	
	dialogue_menu.visible = true
	menu_state = MenuState.OPEN
	anim_player.play("fade_in_out_continue_label")


func close_menu():
	GlobalSettings.stop_movement = false
	
	dialogue_menu.visible = false
	menu_state = MenuState.CLOSED
	anim_player.stop()
