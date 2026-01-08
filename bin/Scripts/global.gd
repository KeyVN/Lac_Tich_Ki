extends Node

#================================multiplayer============================
var is_host := false
var server_ip := "10.29.83.0/24"
var user_name := ""
#================================veget==================================
var plantselected = 0
var numofvegetspecies = 1

var numofveget: Array[int] = [100, 100]
var numofseedpack: Array[int] = [0, 0]
var timeofveget: Array[int] = [4, 5]
var nameofveget: Array[String] = ["carrot", "onion"]

var priceofveget: Array[int] = [2, 3]

#================================tool===============================
enum Tool {
	NONE,
	WATERING_CAN,
	SHOVEL,
	HOE,
	AXE,
	PICKAXE,
	ATTACK_TOOL,
	SEED
}

var toolselected := Tool.NONE

#================================economi==================================
var coins = 10

#================================time==================================
var hours = 7
var minutes = 0
