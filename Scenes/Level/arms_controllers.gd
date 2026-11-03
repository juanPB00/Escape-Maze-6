extends Camera3D

@onready var arms = $arms2

var posisi_awal: Vector3
var rotasi_awal: Vector3

var sedang_mengambil := false
var waktu := 0.0

var idle_amplitude := 0.006
var idle_frequency := 1.8

var smooth_speed := 8.0

var grab_duration := 0.25
var hold_duration := 0.1
var return_duration := 0.3

func _ready():
	if arms == null:
		push_error("arms2 tidak ditemukan!")
		return

	posisi_awal = arms.position
	rotasi_awal = arms.rotation

	randomize()


func _process(delta):
	if arms == null:
		return

	waktu += delta

	if not sedang_mengambil:
		var bob_y = sin(waktu * idle_frequency) * idle_amplitude
		var bob_x = cos(waktu * idle_frequency * 0.8) * idle_amplitude * 0.6
		var bob_z = sin(waktu * idle_frequency * 0.5) * idle_amplitude * 0.3

		var target_pos = posisi_awal + Vector3(
			bob_x,
			bob_y,
			bob_z
		)

		var rot_x = cos(waktu * 2.0) * 0.002
		var rot_y = sin(waktu * 1.5) * 0.003

		var target_rot = rotasi_awal + Vector3(
			rot_x,
			rot_y,
			0
		)

		var smooth = 1.0 - exp(-smooth_speed * delta)

		arms.position = arms.position.lerp(
			target_pos,
			smooth
		)

		arms.rotation = arms.rotation.lerp(
			target_rot,
			smooth
		)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_E:
			if not sedang_mengambil:
				animasi_ambil()


func animasi_ambil():
	sedang_mengambil = true

	arms.position = posisi_awal
	arms.rotation = rotasi_awal

	var posisi_ambil = posisi_awal + Vector3(
		0.02,
		-0.12,
		-0.38
	)

	var rotasi_ambil = rotasi_awal + Vector3(
		deg_to_rad(-15),
		deg_to_rad(3),
		deg_to_rad(6)
	)

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		arms,
		"position",
		posisi_ambil,
		grab_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		arms,
		"rotation",
		rotasi_ambil,
		grab_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished

	await get_tree().create_timer(hold_duration).timeout

	var tween_balik = create_tween()

	tween_balik.set_parallel(true)

	tween_balik.tween_property(
		arms,
		"position",
		posisi_awal,
		return_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	tween_balik.tween_property(
		arms,
		"rotation",
		rotasi_awal,
		return_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	await tween_balik.finished

	arms.position = posisi_awal
	arms.rotation = rotasi_awal

	sedang_mengambil = false
