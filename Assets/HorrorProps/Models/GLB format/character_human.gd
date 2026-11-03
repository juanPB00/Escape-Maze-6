extends CharacterBody3D

@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var mouse_sensitivity := 0.003
@export var gravity := 15.0

var key_count := 0
var max_keys := 3

@onready var ui = get_node("../UI")
@onready var head: Node3D = $Head
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		head.rotate_x(-event.relative.y * mouse_sensitivity)

		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var speed := walk_speed

	if Input.is_action_pressed("sprint"):
		speed = run_speed

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _process(delta):

	if Input.is_action_just_pressed("interact"):
		print("E ditekan!")

		try_interact()


func try_interact():

	if not raycast.is_colliding():
		print("Tidak ada objek di depan Player!")
		return

	var object = raycast.get_collider()

	print("Objek terdeteksi: ", object.name)

	if object.has_method("interact"):
		object.interact(self)
	else:
		print("Objek tidak memiliki fungsi interact()")

func add_key():
	key_count += 1

	print("Key: ", key_count, " / ", max_keys)

	ui.update_keys(key_count, max_keys)
