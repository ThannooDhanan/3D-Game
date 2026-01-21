extends Node3D

@onready var dig_spots := %Checkpoints
@onready var home := %Home
@onready var treasureBank := %"Treasure Bank"
@onready var burriedTreasure := preload("res://Treasures/treasure.tscn")

var activeDigSpot: DigSpot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var randomPoint = randi_range(0, len(dig_spots.get_children()) -1)
	activeDigSpot = dig_spots.get_child(randomPoint)
	for waypoint in dig_spots.get_children():
		waypoint.playerEnteredSite.connect(playerInPoint)
		waypoint.playerLeftSite.connect(playerLeftPoint)
		if waypoint != activeDigSpot:
			waypoint.active = false
			waypoint.visible = false
	setUpActiveDigSpot()

func playerInPoint(digSite: Area3D, player: Player) -> void:
	if digSite.active:
		player.canDig = true
		if !player.finishedDigging.is_connected(onPlayerFinishedDigging):
			player.finishedDigging.connect(onPlayerFinishedDigging.bind(digSite))
		#make home the new active point

func playerLeftPoint(player: Player):
	if player is Player:
		player.canDig = false
		if player.finishedDigging.is_connected(onPlayerFinishedDigging):
			player.finishedDigging.disconnect(onPlayerFinishedDigging)

func setUpActiveDigSpot():
	var table: TreasureTable = treasureBank.TREASURE_BANK[activeDigSpot.level - 1]
	var treasures = table.treasures
	var randomTreasure = treasures[randi_range(0, len(treasures) -1)]
	activeDigSpot.active = true
	activeDigSpot.pointerArrow.visible = true
	activeDigSpot.burriedTreasure = randomTreasure

func onPlayerFinishedDigging(player: Player, digSite: DigSpot):
	print(player.name + " has unearthed treasure!")
	#Instantiate treasure scene
	var treasureInstance = burriedTreasure.instantiate()
	get_tree().current_scene.add_child(treasureInstance)
	
	#Assign the treasure's mesh
	treasureInstance.apply_data(digSite.burriedTreasure)
	
	#Spawn treasure infront of player
	treasureInstance.global_position = player.treasureSpawn.global_position
	
	goHome()

func goHome():
	activeDigSpot.active = false
	activeDigSpot.visible = false
	home.pointerArrow.visible = true
