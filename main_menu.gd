extends Control

@onready var settings_panel = $SettingsPanel
@onready var credit_panel = $CreditPanel
@onready var exit_popup = $ExitPopup
@onready var click_sound = $ClickSound

# =========================
# SLIDER
# =========================

@onready var music_slider = $SettingsPanel/MusicSlider
@onready var sfx_slider = $SettingsPanel/HSlider2

@onready var music_value = $SettingsPanel/MusicSlider/MusicValue
@onready var sfx_value = $SettingsPanel/HSlider2/SFXValue


func _ready():
	# =========================
	# PANEL AWAL
	# =========================

	# Posisi awal Settings Panel disembunyikan di luar layar kanan
	# (1152 adalah lebar layar Anda, ubah jika resolusi berbeda)
	settings_panel.position.x = 1152

	# Credit disembunyikan saat awal
	credit_panel.hide()
	credit_panel.modulate.a = 1.0

	exit_popup.hide()


	# =========================
	# SLIDER
	# =========================

	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1
	music_slider.value = 100

	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.step = 1
	sfx_slider.value = 100

	music_value.text = "100%"
	sfx_value.text = "100%"


# ==================================================
# SETTINGS
# ==================================================

func _on_settings_pressed():
	click_sound.play()

	# Jika Settings sedang terbuka (posisi x = 0) -> tutup
	if settings_panel.position.x == 0:
		var tween = create_tween()
		tween.tween_property(settings_panel, "position:x", 1152, 0.4)
		return

	# Tutup Credit
	credit_panel.hide()

	# Buka Settings (Geser ke posisi 0 / Full Screen)
	var tween = create_tween()
	tween.tween_property(settings_panel, "position:x", 0, 0.4)


func _on_closebutton_pressed():
	click_sound.play()

	var tween = create_tween()
	tween.tween_property(settings_panel, "position:x", 1152, 0.4)


# ==================================================
# MUSIC VOLUME
# ==================================================

func _on_music_slider_value_changed(value):
	# Update angka
	music_value.text = str(int(value)) + "%"

	var bus = AudioServer.get_bus_index("Music")

	if value <= 0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_db(bus, linear_to_db(value / 100.0))


# ==================================================
# SFX VOLUME
# ==================================================

func _on_sfx_slider_value_changed(value):
	# Update angka
	sfx_value.text = str(int(value)) + "%"

	var bus = AudioServer.get_bus_index("SFX")

	if value <= 0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_db(bus, linear_to_db(value / 100.0))


# ==================================================
# CREDIT FULL SCREEN
# ==================================================

func _on_credit_pressed():
	click_sound.play()

	# Tutup Settings
	settings_panel.position.x = 1152

	# Kalau Credit sedang terbuka -> tutup
	if credit_panel.visible:
		var close_tween = create_tween()
		close_tween.tween_property(credit_panel, "modulate:a", 0.0, 0.3)

		await close_tween.finished

		credit_panel.hide()
		credit_panel.modulate.a = 1.0
		return


	# Buka Credit Full Screen
	credit_panel.show()
	credit_panel.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(credit_panel, "modulate:a", 1.0, 0.4)


func _on_closebuttoncredit_pressed():
	click_sound.play()

	var tween = create_tween()
	tween.tween_property(credit_panel, "modulate:a", 0.0, 0.3)

	await tween.finished

	credit_panel.hide()
	credit_panel.modulate.a = 1.0


# ==================================================
# EXIT
# ==================================================

func _on_exit_pressed() -> void:
	click_sound.play()
	exit_popup.show()


func _on_no_button_pressed():
	click_sound.play()
	exit_popup.hide()


func _on_yes_button_pressed():
	click_sound.play()
	await click_sound.finished
	get_tree().quit()
