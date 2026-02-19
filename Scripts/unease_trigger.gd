extends Area3D
class_name UneaseIncreaser

@export_group("Area Status")
@export var triggerable := false
@export_group("Timer Status")
@export var min_reset_timer : float
@export var max_reset_timer : float
@onready var trigger_timer : Timer = %Timer

@export var unease_increase_value : int = 1

func _ready():
	if !triggerable:
		trigger_timer.start(randf_range(min_reset_timer, generate_maximum_cap()))

func _on_body_entered(_body: Node3D) -> void:
	if triggerable:
		print("Increasing Unease!")
		raise_unease()
	
func raise_unease():
	TrapManagement.increase_unease(unease_increase_value)
	triggerable = false


func _on_timer_timeout() -> void:
	triggerable = true

func generate_maximum_cap() -> float:
	var difference := max_reset_timer - TrapManagement.hazard
	var maximum_cap : float = difference if min_reset_timer > difference else min_reset_timer
	return maximum_cap
