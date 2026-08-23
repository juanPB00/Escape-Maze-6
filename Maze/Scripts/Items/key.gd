extends Area3D

func interact(player):
	player.add_key()

	print("Key berhasil diambil!")

	queue_free()
