extends Node2D

# =========================
# 🌦️ WEATHER / TIME
# =========================
@onready var weather = $Weather
@onready var timer = $worldtimer

var growing_zones := {}

# ================= THỜI GIAN =================
var day_length := 1440
var time := 420

# ================= MƯA =================
var is_raining := false
var rain_chance := 0.3

# =========================
# 🚀 READY
# =========================
func _ready():
	# ❗ CHỈ SERVER MỚI CHẠY TIME + WEATHER
	if multiplayer.is_server():
		randomize()
		timer.wait_time = 1.0
		timer.start()
		update_time_state()
		
	# Kết nối tín hiệu khi có người mới vào
	multiplayer.peer_connected.connect(_on_player_connected)
	# Kết nối tín hiệu khi có người thoát
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
# =========================
# MULTIPLAYER
# =========================
func _on_player_connected(id: int):
	# Chỉ Server mới ra lệnh gửi thông báo [cite: 21, 22]
	if multiplayer.is_server():
		var msg = "Người chơi " + str(id) + " đã tham gia vào thế giới!"
		rpc("display_notification", msg)
	
func _on_player_disconnected(id: int):
	var msg = "Người chơi " + str(id) + " đã rời khỏi thế giới."
	rpc("display_notification", msg)

@rpc("any_peer", "call_local")
func display_notification(msg: String):
	# Đảm bảo đường dẫn tới NotificationLayer là chính xác trong World scene [cite: 25]
	if has_node("CanvasLayer/NotificationLayer"):
		$CanvasLayer/NotificationLayer.show_message(msg)
	else:
		# Nếu không có node, in ra console để debug 
		print("Thông báo: ", msg)

# =========================
# ⏱️ TIMER (SERVER ONLY)
# =========================
func _on_worldtimer_timeout():
	if not multiplayer.is_server():
		return

	time += 1.0
	if time >= day_length:
		time = 0.0
		check_rain_for_new_day()

	update_time_state()
	rpc("rpc_sync_time", time)

# =========================
# 🔄 SYNC TIME TO CLIENTS
# =========================
@rpc("authority", "call_remote")
func rpc_sync_time(t: float):
	time = t
	Global.hours = int(time / 60)
	Global.minutes = int(time) % 60
	
	# Cập nhật cho tất cả các con của node players 
	for p in $players.get_children():
		if p.has_node("clock"):
			p.get_node("clock").update_clock_time()

# =========================
# 🌅 TIME STATE
# =========================
func update_time_state():
	var t = time
	if t < 5 * 60:
		weather.set_night()
	elif t < 6 * 60:
		weather.set_dawn()
	elif t < 17 * 60:
		weather.set_day()
	elif t < 18 * 60:
		weather.set_dusk()
	else:
		weather.set_night()

# =========================
# 🌧️ RAIN LOGIC (SERVER)
# =========================
func check_rain_for_new_day():
	if randf() < rain_chance:
		start_rain_for_random_time()
	else:
		weather.stop_rain()
		rpc("rpc_stop_rain")

func start_rain_for_random_time():
	if is_raining:
		return

	is_raining = true
	weather.start_rain()
	rpc("rpc_start_rain")

	var rain_time := randf_range(120, 360)
	await get_tree().create_timer(rain_time).timeout

	weather.stop_rain()
	rpc("rpc_stop_rain")
	is_raining = false

# =========================
# 🌧️ RPC RAIN SYNC
# =========================
@rpc("authority", "call_remote")
func rpc_start_rain():
	weather.start_rain()

@rpc("authority", "call_remote")
func rpc_stop_rain():
	weather.stop_rain()
