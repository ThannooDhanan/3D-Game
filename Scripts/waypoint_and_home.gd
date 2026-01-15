extends Node3D

@onready var dig_spots := %Checkpoints
@onready var home := %Home
@onready var treasureBank := %"Treasure Bank"

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
	setUpActiveDigSpot()
	
	

func playerInPoint(digSite: Area3D, player: Node3D) -> void:
	if player is Player and digSite.active:
		player.canDig = true
		player.finishedDigging.connect(goHome)
		player.finishedDigging.connect(releaseTreasure)
		#wait for the player to finish digging then release treasure
		#make home the new active point
		print("Player " + player.name + " in " + digSite.name)

func playerLeftPoint(player: Node3D):
	if player is Player:
		player.canDig = false

func goHome(_player: Player):
	activeWaypoint.active = false
	activeWaypoint.visible = false

func setUpActiveDigSpot():
	var table: TreasureTable = treasureBank.TREASURE_BANK[activeWaypoint.level - 1]
	var treasures = table.treasures
	var randomTreasure = treasures[randi_range(0, len(treasures) -1)]
	activeWaypoint.active = true
	activeWaypoint.pointerArrow.visible = true
	activeWaypoint.burriedTreasure = randomTreasure

func releaseTreasure(_player: Player):
	var treasureInstance = activeWaypoint.burriedTreasure.instantiate()
	get_tree().current_scene.add_child(treasureInstance)
	treasureInstance.global_position = activeWaypoint.global_position + Vector3(0,1,0)
