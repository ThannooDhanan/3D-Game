extends Node3D

@onready var dig_spots := %Checkpoints
@onready var home := %Home

var activeWaypoint: DigSpot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var randomPoint = randi_range(1, len(dig_spots.get_children())) - 1
	activeWaypoint = dig_spots.get_child(randomPoint)
	for waypoint in dig_spots.get_children():
		waypoint.playerEnteredSite.connect(playerInPoint)
		waypoint.playerLeftSite.connect(playerLeftPoint)
		if waypoint != activeWaypoint:
			waypoint.active = false
			waypoint.visible = false
	activeWaypoint.active = true
	activeWaypoint.pointerArrow.visible = true
	

func playerInPoint(digSite: Area3D, player: Node3D) -> void:
	if player is Player and digSite.active:
		player.canDig = true
		player.finishedDigging.connect(goHome)
		#wait for the player to finish digging then deactivate digSite
		#make home the new active point
		print("Player " + player.name + " in " + digSite.name)

func playerLeftPoint(player: Node3D):
	if player is Player:
		player.canDig = false

func goHome():
	activeWaypoint.active = false
	activeWaypoint.visible = false
