extends Node

func _ready():
	$VBoxContainer/Start_Button.grab_focus()

func _on_Start_Button_pressed():
	get_tree().change_scene("res://scenes/Scene_One.tscn")

func _on_Exit_Button_pressed():
	get_tree().quit()
