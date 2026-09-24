extends CharacterBody3D

@export var speed: float = 3.0
@export var chase_speed: float = 5.0
@export var patrol_points: Array[Node3D] = []
@export var gravity: float = 9.8
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.5

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_point: int = 0
var player: Node3D = null
var is_chasing: bool = false
var is_attacking: bool = false
var is_dead: bool = false
var can_attack: bool = true


func _ready() -> void:
	await get_tree().physics_frame

	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	if patrol_points.is_empty():
		return

	if patrol_points[current_point] != null:
		navigation_agent.target_position = patrol_points[current_point].global_position

	animation_player.play("idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if is_attacking:
		# Diam di tempat sambil menyerang
		velocity.x = 0.0
		velocity.z = 0.0
	elif is_chasing and player != null:
		var distance_to_player := global_position.distance_to(player.global_position)
		if distance_to_player <= attack_range:
			velocity.x = 0.0
			velocity.z = 0.0
			_try_attack()
		else:
			chase_player()
	else:
		patrol()

	move_and_slide()
	_update_animation()


func patrol() -> void:
	if patrol_points.is_empty():
		velocity.x = 0.0
		velocity.z = 0.0
		return

	if navigation_agent.is_navigation_finished():
		current_point += 1
		if current_point >= patrol_points.size():
			current_point = 0

		if patrol_points[current_point] != null:
			navigation_agent.target_position = patrol_points[current_point].global_position
		return

	var next_position := navigation_agent.get_next_path_position()
	var direction := (next_position - global_position)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	_look_at_direction(direction)


func chase_player() -> void:
	if player == null:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	navigation_agent.target_position = player.global_position

	var next_position := navigation_agent.get_next_path_position()
	var direction := (next_position - global_position)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed

	_look_at_direction(direction)


func _try_attack() -> void:
	if not can_attack or is_attacking:
		return

	is_attacking = true
	can_attack = false
	animation_player.play("attack")

	# Hadap ke player saat menyerang
	var direction := (player.global_position - global_position)
	direction.y = 0.0
	if direction.length() > 0.01:
		_look_at_direction(direction.normalized())


func _on_attack_animation_finished() -> void:
	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	animation_player.play("hit")
	# TODO: kurangi HP di sini

	# contoh: kalau HP habis
	# if hp <= 0:
	#     die()


func die() -> void:
	is_dead = true
	is_chasing = false
	is_attacking = false
	velocity = Vector3.ZERO
	animation_player.play("death")
	set_physics_process(false)
	# opsional: matikan collision
	# $CollisionShape3D.set_deferred("disabled", true)


func _look_at_direction(direction: Vector3) -> void:
	if direction.length() > 0.01:
		var target_angle := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 0.1)


func _update_animation() -> void:
	if is_dead or is_attacking:
		return  # jangan interupsi animasi attack/death dengan idle/moving

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.1:
		if animation_player.current_animation != "moving":
			animation_player.play("moving")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		is_chasing = true
		print("PLAYER TERDETEKSI!")


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		is_chasing = false
		print("PLAYER HILANG!")
