extends Area3D
class_name PointOfInterest

@onready var pointerArrow := %Arrow
@export var active := false

signal playerEnteredSite(digSite: Area3D, player: Node3D)
signal playerLeftSite(player: Node3D)

func _ready():
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if !body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	print("Entered : " + name + " by " + body.name)
	if body is Player:
		emit_signal("playerEnteredSite", self, body)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		emit_signal("playerLeftSite", body)
