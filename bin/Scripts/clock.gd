extends StaticBody2D

var H : String = ""
var M : String = ""

func update_clock_time():
	H = str(Global.hours)
	if Global.hours < 10: H = '0' + H
	M = str(Global.minutes)
	if Global.minutes < 10: M = '0' + M
	$clocktime.text = (H + ':' + M)
