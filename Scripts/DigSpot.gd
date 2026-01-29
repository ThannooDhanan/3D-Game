extends PointOfInterest
class_name DigSpot

@export_range(1,3) var level: int = 1

@onready var burriedTreasure : Collectable

func _ready() -> void:
	if !active:
		pointerArrow.visible = false 
	else:
		pass
