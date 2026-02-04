extends Node3D

@onready var dig_spots := %Checkpoints
@onready var home := %Home
@onready var treasureBank := %"Treasure Bank"
@export var burriedTreasure : PackedScene #= preload("res://Treasures/treasure.tscn")
@export var treasureUneasePenalty := 3

var activeDigSpot: DigSpot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setUpWorldTrapTimer()
	setUpPoints()
	setUpHome()

func setUpWorldTrapTimer():
	TrapManagement.hazard_and_unease_timer.autostart = true
	TrapManagement.set_starting_trap_properties()
	TrapManagement.hazard_and_unease_timer.start()

func setUpPoints():
	var randomPoint = randi_range(0, len(dig_spots.get_children()) -1)
	activeDigSpot = dig_spots.get_child(randomPoint)
	for waypoint in dig_spots.get_children():
		waypoint.playerEnteredSite.connect(playerInPoint)
		waypoint.playerLeftSite.connect(playerLeftPoint)
		if waypoint != activeDigSpot:
			waypoint.active = false
			waypoint.visible = false
	setUpActiveDigSpot()

func playerInPoint(site: Area3D, player: Player) -> void:
	if site.active and site is DigSpot:
		player.canDig = true
		if !player.finishedDigging.is_connected(onPlayerFinishedDigging):
			player.finishedDigging.connect(onPlayerFinishedDigging)
	#make home the new active point
	if site is Home and player.treasureInHand != null:
		player.canCashout = true
		if !player.relinquishTreasure.is_connected(cashoutTreasure):
			player.relinquishTreasure.connect(cashoutTreasure)

func playerLeftPoint(player: Player):
	#this function must disconnect all signals from the player to the Points of Interest
	#If the player is not in a point of interest, the signal shouldn't be listened to.
	player.canDig = false
	player.canCashout = false
	if player.finishedDigging.is_connected(onPlayerFinishedDigging):
		player.finishedDigging.disconnect(onPlayerFinishedDigging)
	if player.relinquishTreasure.is_connected(cashoutTreasure):
		player.relinquishTreasure.disconnect(cashoutTreasure)

func setUpActiveDigSpot():
	var table: TreasureTable = treasureBank.TREASURE_BANK[activeDigSpot.level - 1]
	var treasures = table.treasures
	var randomTreasure = treasures[randi_range(0, len(treasures) -1)]
	activeDigSpot.active = true
	activeDigSpot.pointerArrow.visible = true
	activeDigSpot.burriedTreasure = randomTreasure

func disablePointOfInterestConnection(site: PointOfInterest):
	if site.playerEnteredSite.is_connected(playerInPoint):
		site.playerEnteredSite.disconnect(playerInPoint)
	if site.playerLeftSite.is_connected(playerLeftPoint):
		site.playerLeftSite.disconnect(playerLeftPoint)
	

func onPlayerFinishedDigging(player: Player):
	#Instantiate treasure scene
	if burriedTreasure != null:
		var treasureInstance = burriedTreasure.instantiate()
		TrapManagement.unease += treasureUneasePenalty
		get_tree().current_scene.add_child(treasureInstance)
	
		#Assign the treasure's mesh
		treasureInstance.apply_data(activeDigSpot.burriedTreasure)
	
		#Spawn treasure infront of player
		treasureInstance.global_position = player.treasureSpawn.global_position
	
		disablePointOfInterestConnection(activeDigSpot)
	
		activateHome()

func playerLeftHome():
	print("Player left home")
	pass

func setUpHome():
	if !home.playerEnteredSite.is_connected(playerInPoint):
		home.playerEnteredSite.connect(playerInPoint)

func activateHome():
	activeDigSpot.active = false
	activeDigSpot.visible = false
	home.pointerArrow.visible = true
	home.active = true

func cashoutTreasure(player: Player):
	
	print("Player has cashed out treasure worth: ", player.treasureInHand.worth)
