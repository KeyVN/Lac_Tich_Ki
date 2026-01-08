extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	# Kết nối tín hiệu khi có người chơi khác tham gia
	multiplayer.peer_connected.connect(spawn_player)
	
	# Chỉ Server (Host) mới thực hiện việc spawn
	if multiplayer.is_server():
		# Tự tạo nhân vật cho chính mình (ID của Host luôn là 1)
		# Dùng call_deferred để đảm bảo hệ thống mạng đã sẵn sàng
		spawn_player.call_deferred(1)

func spawn_player(id: int) -> void:
	# Chỉ server mới có quyền spawn node 
	if !multiplayer.is_server():
		return 

	# Lấy node chứa các player dựa trên spawn_path đã cài đặt 
	var container = get_node(spawn_path)
	
	# Kiểm tra nếu nhân vật này đã tồn tại thì không tạo thêm
	if container.has_node(str(id)):
		return

	# Tạo instance nhân vật mới 
	var player: Node = network_player.instantiate()

	# Đặt tên node theo ID để đồng bộ hóa 
	player.name = str(id)

	# Thêm vào cây thư mục của game 
	container.add_child(player)
