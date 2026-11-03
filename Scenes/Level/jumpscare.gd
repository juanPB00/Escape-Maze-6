extends Area3D


@export var scare_duration := 1.5

@onready var scare_object = $JumpScareObject

var sudah_trigger := false


func _ready():

	body_entered.connect(_on_body_entered)

	scare_object.visible = false


func _on_body_entered(body):

	if sudah_trigger:
		return

	if body.name != "Player":
		return

	sudah_trigger = true

	scare_object.visible = true

	print("JUMPSCARE!")

	await get_tree().create_timer(
		scare_duration
	).timeout

	scare_object.visible = false
