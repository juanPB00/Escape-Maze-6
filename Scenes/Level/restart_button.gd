extends Button

func _ready():
	pressed.connect(restart_game)

func restart_game():
	get_tree().reload_current_scene()
