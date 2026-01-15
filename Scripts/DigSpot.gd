extends PointOfInterest
class_name DigSpot

@export_range(1,3) var level: int = 1

var burriedTreasure : PackedScene

func _ready() -> void:
	if !active:
		pointerArrow.visible = false 
	else:
		pass

func _on_body_entered(body: Node3D):
	if body is Player:
		emit_signal("playerEnteredSite", self, body)
		if !body.finishedDigging.is_connected(player_has_dugup_treasure):
			body.finishedDigging.connect(player_has_dugup_treasure)

func player_has_dugup_treasure(player: Player):
	print(player.name + " has unearthed treasure!")
	
