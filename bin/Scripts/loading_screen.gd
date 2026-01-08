extends CanvasLayer

func finish():
	# Hiệu ứng mờ dần trước khi xóa
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
