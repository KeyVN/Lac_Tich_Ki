extends StaticBody2D

var items = [
	{
		"name": "Carrot Seed",
		"price": 1,
		"ani" : "carrotseed"
	},
	{
		"name": "Onion Seed",
		"price": 2,
		"ani" : "onionseed"
	}
]

var index := 0

func open():
	visible = true
	update_ui()

func close():
	visible = false


func update_ui():
	var item = items[index]
	$pricelabel.text = str(item.price)
	$icon.play(item.ani)

func _on_buttonright_pressed() -> void:
	index += 1
	if index >= items.size():
		index = 0
	update_ui()

func _on_buttonleft_pressed() -> void:
	index -= 1
	if index < 0:
		index = items.size() - 1
	update_ui()

func _on_buttonbuy_pressed() -> void:
	var item = items[index]
	if Global.coins < item.price:
		return
	Global.numofseedpack[index] += 1
	Global.coins -= item.price
	var player = get_tree().get_root().get_node("world/player")
	if player:
		player.update_ui()
