extends Node

@export_group("Trap")
@export_range(0, 25) var hazard: int = 0
@export_range(0, 25) var unease: int = 0
@export var max_hazard: int = 25
@export var max_unease: int = 25

@export_group("Bonuses")
@export var extra_gold_coin : int = 0
@export var extra_souls : int = 0

@export_group("Blocks")
@export var harzard_block : int = 1
@export var unease_block : int = 0

@export_group("Timer parameters")
var hazard_timer: Timer
@export var time_until_increase : float = 2.5
@export var min_hazard_timeout_inc : int = 1
@export var max_hazard_timeout_inc : int = 3

signal hazard_increased
signal unease_increased

func _ready():
	randomize()
	hazard_timer = Timer.new()
	add_child(hazard_timer)
	hazard_timer.autostart = false
	hazard_timer.wait_time = time_until_increase
	hazard_timer.stop()
	hazard_timer.connect("timeout", increase_trap_values)
	
	#These Two can be removed later
	hazard_increased.connect(print_hazard)
	unease_increased.connect(print_unease)

func set_starting_trap_properties():
	hazard = randi_range(0, 5)
	unease = randi_range(0, 5)
	hazard_increased.emit()
	unease_increased.emit()

func increase_trap_values():
	var hazard_increase = randi_range(min_hazard_timeout_inc, max_hazard_timeout_inc)
	increase_hazard(hazard_increase)
	
func start_hazard_timer():
	hazard_timer.start()

func increase_hazard(value : int):
	if harzard_block > 0:
		harzard_block -= value
		print("hazard was blocked")
		if harzard_block < 0:
			print("hazard was not fully blocked")
			hazard += (harzard_block * -1)
			harzard_block = 0
			clamp_hazard()
	elif hazard < max_hazard:
		hazard += value
		clamp_hazard()
	hazard_increased.emit()

func increase_hazard_unblocked(value: int):
	hazard += value
	hazard_increased.emit()

func increase_unease(value: int):
	if unease_block > 0:
		unease_block -= value
		if unease_block < 0:
			unease += (unease_block * -1)
			unease_block = 0
			clam_unease()
	elif unease < max_unease:
		unease += value
		clam_unease()
	unease_increased.emit()

func increase_unease_unblocked(value: int):
	unease += value
	unease_increased.emit()

func print_hazard():
	print("Hazard is now ", hazard)

func print_unease():
	print("Unease is now ", unease)

func clamp_hazard():
	if hazard > max_hazard:
		print("Maximum hazard reached")
		hazard = max_hazard

func clam_unease():
	if unease > max_unease:
		print("Maximum unease reached")
		unease = max_unease
