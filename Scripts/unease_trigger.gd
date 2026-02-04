extends Area3D
class_name UneaseIncreaser

@export_group("Area Status")
@export var triggerable := false
@export var reset_timer : float
@onready var trigger_timer : Timer = %Timer

@export var unease_increase_value : int = 1

func _ready():
	if !triggerable:
		trigger_timer.start(reset_timer)

func _on_body_entered(_body: Node3D) -> void:
	print("Increasing Unease!")
	if triggerable:
		raise_unease()
	
func raise_unease():
	TrapManagement.increase_unease(unease_increase_value)
	triggerable = false


func _on_timer_timeout() -> void:
	triggerable = true
