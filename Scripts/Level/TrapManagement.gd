extends Node

@export_group("Trap")
@export var hazard: int = 0
@export var unease: int = 0

@export_group("Bonuses")
@export var extra_gold_coin : int = 0
@export var extra_souls : int = 0

@export_group("Blocks")
@export var harzard_block : int = 0
@export var unease_block : int = 0

@export_group("Timer parameters")
var hazard_and_unease_timer: Timer
@export var time_until_increase : float = 2.5

signal hazard_increased
signal unease_increased

func _ready():
	hazard_and_unease_timer = Timer.new()
	add_child(hazard_and_unease_timer)
	hazard_and_unease_timer.autostart = false
	hazard_and_unease_timer.wait_time = time_until_increase
	hazard_and_unease_timer.stop()
	hazard_and_unease_timer.connect("timeout", increaseTrapValues)
	hazard_increased.connect(print_hazard)
	unease_increased.connect(print_unease)

func set_starting_trap_properties():
	hazard = randi_range(0, 5)
	unease = randi_range(0, 5)
	hazard_increased.emit()
	unease_increased.emit()

func increaseTrapValues():
	var hazard_increase = randi_range(0, 2)
	var unease_increase = randi_range(0, 2)
	increase_hazard(hazard_increase)
	increase_unease(unease_increase)
	

func increase_hazard(value : int):
	if harzard_block > 0:
		harzard_block -= value
		if harzard_block < 0:
			hazard += (harzard_block * -1)
			harzard_block = 0
	else:
		hazard += value
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
	else:
		unease += value
	unease_increased.emit()

func increase_unease_unblocked(value: int):
	unease += value
	unease_increased.emit()

func print_hazard():
	print("Hazard is now ", hazard)

func print_unease():
	print("Unease is now ", unease)
