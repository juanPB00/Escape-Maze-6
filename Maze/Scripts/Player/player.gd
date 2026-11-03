extends CharacterBody3D


@export var speed := 5.0
@export var sprint_speed := 8.0
@export var mouse_sensitivity := 0.002
@export var gravity := 15.0


# =========================
# EFEK NAPAS TANGAN
# =========================

@export var breathing_speed := 3.0
@export var breathing_amount := 0.025


# =========================
# EFEK HEAD BOB
# =========================

@export var bob_speed := 7.0
@export var bob_amount := 0.015


# =========================
# FLASHLIGHT
# =========================

@export var flashlight_energy := 2.0
@export var flicker_chance := 0.04
@export var flicker_min_energy := 0.8
@export var flicker_max_energy := 2.0

@export var max_battery := 100.0
@export var battery_drain := 10.0
@export var battery_regen := 10.0

var battery := 100.0


# =========================
# STAMINA
# =========================

@export var max_stamina := 100.0
@export var stamina_drain := 15.0
@export var stamina_regen := 20.0

var stamina := 100.0


var jumlah_kunci := 0
var health := 100
var sudah_mati := false

var flashlight_on := true


# =========================
# VARIABEL NAPAS
# =========================

var breathing_time := 0.0

var arms_start_position := Vector3.ZERO
var arms_start_rotation := Vector3.ZERO


# =========================
# VARIABEL HEAD BOB
# =========================

var bob_time := 0.0
var camera_start_position := Vector3.ZERO


# =========================
# NODE
# =========================

@onready var ui = get_parent().get_node("UI")

@onready var health_bar = get_parent().get_node("UI/HealthBar")

@onready var stamina_bar = get_parent().get_node("UI/StaminaBar")

@onready var objective_label = get_parent().get_node("UI/ObjectiveLabel")

@onready var battery_bar = get_parent().get_node("UI/BatteryBar")

@onready var low_health_vignette = get_parent().get_node(
	"UI/LowHealthVignette"
)

@onready var game_over = get_parent().get_node("GameOver")

@onready var animation_player = get_parent().get_node(
	"GameOver/AnimationPlayer"
)

@onready var restart_button = get_parent().get_node(
	"GameOver/Panel/RestartButton"
)


@onready var head = $Head

@onready var camera = $Head/Camera3D

@onready var raycast = $Head/Camera3D/RayCast3D

@onready var arms = $Head/Camera3D/arms2


# =========================
# FLASHLIGHT NODE
# =========================

@onready var flashlight = $Head/Camera3D/arms2/arms_armature/Skeleton3D/RightHandAttachment/Flashlight

@onready var flashlight_light = $Head/Camera3D/arms2/arms_armature/Skeleton3D/RightHandAttachment/Flashlight/SpotLight3D


func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	raycast.enabled = true


	# =========================
	# HEALTH
	# =========================

	health = 100

	sudah_mati = false

	health_bar.min_value = 0

	health_bar.max_value = 100

	health_bar.value = 100

	health_bar.modulate = Color(0.3, 1.0, 0.3)

	# VIGNETTE AWAL MATI
	low_health_vignette.color = Color(
		1.0,
		0.0,
		0.0,
		0.0
	)


	# =========================
	# STAMINA
	# =========================

	stamina = max_stamina

	stamina_bar.min_value = 0

	stamina_bar.max_value = max_stamina

	stamina_bar.value = stamina


	# =========================
	# OBJECTIVE
	# =========================

	objective_label.text = "Temukan 3 Kunci Dulu!!!"


	# =========================
	# BATTERY
	# =========================

	battery = max_battery

	battery_bar.min_value = 0

	battery_bar.max_value = max_battery

	battery_bar.value = battery

	battery_bar.modulate = Color(0.3, 1.0, 0.3)


	# =========================
	# GAME OVER
	# =========================

	game_over.visible = false

	restart_button.visible = false


	# =========================
	# SIMPAN POSISI TANGAN
	# =========================

	arms_start_position = arms.position

	arms_start_rotation = arms.rotation


	# =========================
	# SIMPAN POSISI KAMERA
	# =========================

	camera_start_position = camera.position


	# =========================
	# FLASHLIGHT
	# =========================

	flashlight_on = true

	flashlight_light.visible = true

	flashlight_light.light_energy = flashlight_energy


func _unhandled_input(event):

	if sudah_mati:
		return


	# =========================
	# MOUSE LOOK
	# =========================

	if event is InputEventMouseMotion:

		rotate_y(
			-event.relative.x * mouse_sensitivity
		)

		head.rotate_x(
			-event.relative.y * mouse_sensitivity
		)

		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)


	# =========================
	# TOMBOL E
	# =========================

	if event is InputEventKey:

		if event.pressed \
		and not event.echo \
		and event.keycode == KEY_E:

			ambil_objek()


	# =========================
	# TOMBOL F = FLASHLIGHT
	# =========================

	if event is InputEventKey:

		if event.pressed \
		and not event.echo \
		and event.keycode == KEY_F:

			# Tidak bisa menyalakan flashlight
			# kalau baterai habis

			if battery <= 0.0:

				flashlight_on = false

				flashlight_light.visible = false

				print("Baterai senter habis!")

			else:

				flashlight_on = not flashlight_on

				flashlight_light.visible = flashlight_on

				if flashlight_on:

					flashlight_light.light_energy = flashlight_energy

					print("Flashlight ON")

				else:

					flashlight_light.visible = false

					print("Flashlight OFF")


	# =========================
	# ESC
	# =========================

	if event is InputEventKey:

		if event.pressed \
		and not event.echo \
		and event.keycode == KEY_ESCAPE:

			Input.set_mouse_mode(
				Input.MOUSE_MODE_VISIBLE
			)


		if event.pressed \
		and event.keycode == KEY_ENTER:

			Input.set_mouse_mode(
				Input.MOUSE_MODE_CAPTURED
			)


func _physics_process(delta):

	if sudah_mati:
		return


	# =========================
	# GRAVITY
	# =========================

	if not is_on_floor():

		velocity.y -= gravity * delta

	else:

		velocity.y = 0.0


	# =========================
	# WASD
	# =========================

	var input_dir := Vector2.ZERO


	if Input.is_key_pressed(KEY_W):

		input_dir.y -= 1.0


	if Input.is_key_pressed(KEY_S):

		input_dir.y += 1.0


	if Input.is_key_pressed(KEY_A):

		input_dir.x -= 1.0


	if Input.is_key_pressed(KEY_D):

		input_dir.x += 1.0


	input_dir = input_dir.normalized()


	# =========================
	# ARAH GERAKAN
	# =========================

	var direction := (
		transform.basis * Vector3(
			input_dir.x,
			0,
			input_dir.y
		)
	).normalized()


	# =========================
	# SPRINT + STAMINA
	# =========================

	var current_speed := speed

	var sedang_bergerak := direction.length() > 0.1

	var sedang_sprint := (
		Input.is_key_pressed(KEY_SHIFT)
		and sedang_bergerak
		and stamina > 0
	)


	if sedang_sprint:

		current_speed = sprint_speed

		stamina -= stamina_drain * delta

	else:

		stamina += stamina_regen * delta


	# =========================
	# BATASI STAMINA
	# =========================

	stamina = clamp(
		stamina,
		0.0,
		max_stamina
	)


	# =========================
	# UPDATE STAMINA BAR
	# =========================

	stamina_bar.value = stamina

	var stamina_percent := stamina / max_stamina


	if stamina_percent > 0.5:

		stamina_bar.modulate = Color(
			0.3,
			1.0,
			0.3
		)

	elif stamina_percent > 0.2:

		stamina_bar.modulate = Color(
			1.0,
			0.85,
			0.2
		)

	else:

		stamina_bar.modulate = Color(
			1.0,
			0.2,
			0.2
		)


	# =========================
	# GERAK PLAYER
	# =========================

	if direction:

		velocity.x = direction.x * current_speed

		velocity.z = direction.z * current_speed

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			speed * 8.0 * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			speed * 8.0 * delta
		)


	move_and_slide()


func _process(delta):

	if sudah_mati:
		return


	# =========================
	# ANIMASI NAPAS TANGAN
	# =========================

	breathing_time += delta * breathing_speed

	var breathing := sin(
		breathing_time
	)


	arms.position = (
		arms_start_position
		+ Vector3(
			0,
			breathing * breathing_amount,
			breathing * breathing_amount * 0.5
		)
	)


	arms.rotation = (
		arms_start_rotation
		+ Vector3(
			breathing * 0.01,
			0,
			breathing * 0.005
		)
	)


	# =========================
	# HEAD BOB
	# =========================

	var horizontal_velocity := Vector2(
		velocity.x,
		velocity.z
	).length()


	if is_on_floor() and horizontal_velocity > 0.1:

		bob_time += (
			delta
			* bob_speed
			* (horizontal_velocity / speed)
		)


		var bob_y := sin(
			bob_time * 2.0
		) * bob_amount


		var bob_x := cos(
			bob_time
		) * bob_amount * 0.5


		camera.position = (
			camera_start_position
			+ Vector3(
				bob_x,
				bob_y,
				0
			)
		)

	else:

		camera.position = camera.position.lerp(
			camera_start_position,
			delta * 8.0
		)


	# =========================
	# FLASHLIGHT FLICKER
	# =========================

	if flashlight_on:

		if randf() < flicker_chance * delta * 60.0:

			flashlight_light.light_energy = randf_range(
				flicker_min_energy,
				flicker_max_energy
			)

		else:

			flashlight_light.light_energy = lerp(
				flashlight_light.light_energy,
				flashlight_energy,
				delta * 10.0
			)


	# =========================
	# FLASHLIGHT BATTERY
	# =========================

	if flashlight_on:

		battery -= battery_drain * delta

	else:

		battery += battery_regen * delta


	# =========================
	# BATASI BATTERY
	# =========================

	battery = clamp(
		battery,
		0.0,
		max_battery
	)


	# =========================
	# UPDATE BATTERY BAR
	# =========================

	battery_bar.value = battery

	var battery_percent := battery / max_battery


	if battery_percent > 0.5:

		battery_bar.modulate = Color(
			0.3,
			1.0,
			0.3
		)

	elif battery_percent > 0.2:

		battery_bar.modulate = Color(
			1.0,
			0.85,
			0.2
		)

	else:

		battery_bar.modulate = Color(
			1.0,
			0.2,
			0.2
		)


	# =========================
	# BATTERY HABIS
	# =========================

	if battery <= 0.0:

		battery = 0.0

		flashlight_on = false

		flashlight_light.visible = false

		flashlight_light.light_energy = 0.0


func ambil_objek():

	if not raycast.is_colliding():

		print("Tidak ada objek di depan.")

		return


	var objek = raycast.get_collider()


	if objek == null:

		return


	print(
		"Objek terkena RayCast: ",
		objek.name
	)


	if objek.has_method("interact"):

		objek.interact(self)


func add_key():

	jumlah_kunci += 1

	print(
		"Jumlah kunci: ",
		jumlah_kunci
	)


	if ui:

		ui.update_keys(
			jumlah_kunci,
			3
		)


	# =========================
	# UPDATE OBJECTIVE
	# =========================

	var sisa_kunci := 3 - jumlah_kunci


	if sisa_kunci > 1:

		objective_label.text = "Temukan %d Kunci Dulu!!!" % sisa_kunci

	elif sisa_kunci == 1:

		objective_label.text = "Temukan 1 Kunci Lagi!!!"

	else:

		objective_label.text = "Terakhir Temukan Pintu Keluar"


func take_damage(damage):

	if sudah_mati:

		return


	health -= damage

	health = max(
		health,
		0
	)

	health_bar.value = health


	var health_percent := float(health) / 100.0


	# =========================
	# HEALTH BAR COLOR
	# =========================

	if health_percent > 0.5:

		health_bar.modulate = Color(
			0.3,
			1.0,
			0.3
		)

	elif health_percent > 0.2:

		health_bar.modulate = Color(
			1.0,
			0.85,
			0.2
		)

	else:

		health_bar.modulate = Color(
			1.0,
			0.2,
			0.2
		)


	# =========================
	# LOW HEALTH VIGNETTE
	# =========================

	if health_percent <= 0.2:

		var vignette_strength := 1.0 - (
			health_percent / 0.2
		)

		vignette_strength = clamp(
			vignette_strength,
			0.0,
			1.0
		)

		low_health_vignette.color = Color(
			1.0,
			0.0,
			0.0,
			vignette_strength * 0.45
		)

	else:

		low_health_vignette.color = Color(
			1.0,
			0.0,
			0.0,
			0.0
		)


	print(
		"Health: ",
		health
	)


	print(
		"HealthBar Value: ",
		health_bar.value
	)


	if health <= 0:

		mati()


func mati():

	sudah_mati = true

	velocity = Vector3.ZERO


	# =========================
	# MATIKAN FLASHLIGHT
	# =========================

	flashlight_on = false

	flashlight_light.visible = false


	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE
	)


	print("EAAAA MATII")


	# =========================
	# TAMPILKAN GAME OVER
	# =========================

	game_over.visible = true


	# =========================
	# MATIKAN RESTART DULU
	# =========================

	restart_button.visible = false


	# =========================
	# JALANKAN ANIMASI YOU DIED
	# =========================

	if animation_player.has_animation(
		"game_over"
	):

		animation_player.play(
			"game_over"
		)

		print(
			"Animasi Game Over dimulai"
		)

	else:

		print(
			"Animasi game_over tidak ditemukan!"
		)


	# =========================
	# TUNGGU 2 DETIK
	# =========================

	await get_tree().create_timer(
		2.0
	).timeout


	# =========================
	# TAMPILKAN RESTART
	# =========================

	restart_button.visible = true

	restart_button.disabled = false


	print(
		"RESTART MUNCUL"
	)
