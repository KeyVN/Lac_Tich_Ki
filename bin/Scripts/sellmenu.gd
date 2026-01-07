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

@onready var totalsell := 0

func open():
	visible = true
	update_ui()

func close():
	visible = false

var ncarrots := 0
var nonions := 0

func update_ui():
	totalsell = ncarrots * Global.priceofveget[0] + nonions * Global.priceofveget[1]
	$numcarrots.text = str(ncarrots)
	$numonions.text = str(nonions)
	$totalsell.text = str(totalsell)

func _on_onionup_pressed() -> void:
	nonions += 1
	update_ui()

func _on_carrotup_pressed() -> void:
	ncarrots += 1
	update_ui()

func _on_buttonsell_pressed() -> void:
	Global.coins += totalsell
	Global.numofveget[0] -= ncarrots
	Global.numofveget[1] -= nonions
	ncarrots = 0
	nonions = 0
	update_ui()
	var player = get_tree().get_root().get_node("world/player")
	if player:
		player.update_ui()
