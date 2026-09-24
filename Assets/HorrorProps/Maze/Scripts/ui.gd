extends CanvasLayer

@onready var key_label: Label = $KeyLabel

func _ready():
	key_label.position = Vector2(30, 30)
	key_label.add_theme_font_size_override("font_size", 24)
	update_keys(0, 3)

func update_keys(current_keys, max_keys):
	key_label.text = "Keys: %d / %d" % [current_keys, max_keys]
