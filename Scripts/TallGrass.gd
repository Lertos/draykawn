extends Node2D

@onready var anim_player = $AnimationPlayer


func on_body_entered(_body):
	anim_player.play("stepped")


func on_body_exited(_body):
	anim_player.play("idle")


func on_inner_area_entered(_body):
	$ForegroundGrass.visible = true


func on_inner_area_exited(_body):
	$ForegroundGrass.visible = false
