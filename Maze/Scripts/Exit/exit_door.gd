extends Area3D

func interact(player):
	if player.key_count >= player.max_keys:
		print("Semua key sudah dikumpulkan!")
		print("PINTU TERBUKA!")
		
		# Nanti kita buat animasi pintu di sini
		
		win_game()
	else:
		print("Pintu terkunci!")
		print("Key kamu: ", player.key_count, " / ", player.max_keys)


func win_game():
	print("================================")
	print("        YOU WIN!")
	print("   MAZE ESCAPE SELESAI!")
	print("================================")
