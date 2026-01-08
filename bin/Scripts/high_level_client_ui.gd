extends Control

@onready var ip_input = $VBoxContainer/IPInput # Tham chiếu đến ô nhập IP

func _on_server_pressed() -> void:
	Network.start_server()
	self.hide() # Ẩn menu sau khi host

func _on_client_pressed() -> void:
	var target_ip = ip_input.text
	Network.start_client(target_ip)
	self.hide()
