extends Node2D

@onready var canvas: CanvasModulate = $CanvasModulate

var is_raining := false
var time_state := "day"
# "dawn", "day", "dusk", "night"

# ================= MƯA =================
func start_rain():
	is_raining = true
	update_world_color()

	$RainParticles.emitting = true

func stop_rain():
	is_raining = false
	update_world_color()

	$RainParticles.emitting = false


# ================= THỜI ĐIỂM TRONG NGÀY =================
func set_dawn(): # 🌅 bình minh
	time_state = "dawn"
	update_world_color()

func set_day(): # ☀️ ban ngày
	time_state = "day"
	update_world_color()

func set_dusk(): # 🌇 hoàng hôn
	time_state = "dusk"
	update_world_color()

func set_night(): # 🌙 ban đêm
	time_state = "night"
	update_world_color()


# ================= MÀU TỔNG HỢP =================
func update_world_color():
	var base_color: Color

	match time_state:
		"dawn":
			base_color = Color(1.0, 0.85, 0.7)   # vàng hồng sáng
		"day":
			base_color = Color(1, 1, 1)
		"dusk":
			base_color = Color(0.9, 0.6, 0.5)    # cam tím
		"night":
			base_color = Color(0.3, 0.3, 0.5)    # xanh đêm
		_:
			base_color = Color(1, 1, 1)

	# nếu đang mưa → tối & lạnh hơn
	if is_raining:
		base_color *= Color(0.75, 0.75, 0.8)

	fade_to(base_color, 2.0)


# ================= FADE =================
func fade_to(target_color: Color, time := 1.5):
	var tween = create_tween()
	tween.tween_property(canvas, "color", target_color, time)
