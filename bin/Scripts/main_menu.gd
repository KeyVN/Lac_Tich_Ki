extends Control

@onready var ip_input = $VBoxContainer/IPInput

func _on_host_button_pressed():
	# 1. Gọi Network để tạo Server
	Network.start_server()
	# 2. Chuyển sang cảnh World ngay lập tức
	goto_world()

func _on_join_button_pressed():
	var ip = ip_input.text
	if ip == "": ip = "localhost"
	
	# 1. Gọi Network để kết nối tới Host
	Network.start_client(ip)
	# 2. Đợi một chút để kết nối bắt đầu rồi chuyển cảnh
	goto_world()

@export var loading_screen_scene: PackedScene # Kéo file .tscn vào đây

func goto_world():
	# 1. Tạo loading screen và thêm vào Root của game để nó không bị mất khi đổi scene
	var loader = loading_screen_scene.instantiate()
	get_tree().root.add_child(loader)
	
	# 2. Chuyển sang World
	get_tree().change_scene_to_file("res://bin/Scenes/world.tscn")
	
	# 3. Sau khi World load xong, bảo loading screen tự xóa
	# (Chúng ta sẽ gọi hàm finish() từ bên World sau khi mọi thứ đã sẵn sàng)
