extends Node

const PORT: int = 42096 
var peer: ENetMultiplayerPeer

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

# Thêm tham số ip_address vào đây
func start_client(ip_address: String) -> void:
	if ip_address == "": 
		ip_address = "localhost" # Mặc định nếu để trống
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
