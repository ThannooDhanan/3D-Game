extends Node3D
class_name Treasure

@onready var contactBox := %ContactBox
@onready var collider := $CollisionShape3D
@onready var skin := %Skin
@onready var physics_material := "res://Materials/Physics/Frictionless.tres"

var velocity := Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Treasure properties")
@export var displayName : String
@export_range(5,50) var value: int 


func _physics_process(delta: float):
	#simple rotation for the object
	skin.rotate(Vector3.UP, delta)
	velocity.y -= (gravity * delta)
	velocity.y = clamp(velocity.y, -300, 10)


func _on_contact_box_body_entered(body: Node3D):
	if body is Player:
		body.treasureInHand = self
		print("in inventory!")
		visible = false
		collider.call_deferred("set", "disabled", true)
		#process_mode = Node.PROCESS_MODE_DISABLED

func _on_body_entered(body: Node) -> void:
	#collision layer 2 is the ground
	if(body.collision_layer == 2):
		self.physics_material_override.friction = 0.5
	#make the treasue slide off any surface it's resting on
	else:
		self.physics_material_override.friction = 0.25
