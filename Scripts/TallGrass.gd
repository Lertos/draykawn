extends Node2D

@onready var anim_player = $AnimationPlayer


func on_body_entered(body):
	anim_player.play("stepped")


func on_body_exited(body):
	anim_player.play("idle")
