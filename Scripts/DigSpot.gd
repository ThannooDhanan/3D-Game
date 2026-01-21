extends PointOfInterest
class_name DigSpot

@export_range(1,3) var level: int = 1

@onready var burriedTreasure : Collectable

func _ready() -> void:
	if !active:
		pointerArrow.visible = false 
	else:
		pass

func _on_body_entered(body: Node3D):
	if body is Player and active:
		emit_signal("playerEnteredSite", self, body)
