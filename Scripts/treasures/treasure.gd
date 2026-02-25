extends Node3D
class_name Treasure

@onready var contactBox := %ContactBox
@onready var collider := $CollisionShape3D
@onready var skin := %Skin
@onready var floorChecker := $RayCast3D
@onready var physics_material := "res://Materials/Physics/Frictionless.tres"

var velocity := Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var tween_time := 3.0

var treasure_data : Collectable

func apply_data(p_treasure_data: Collectable):
	treasure_data = p_treasure_data
	skin.mesh = p_treasure_data.display_mesh

func _ready():
	#simple rotation for the object
	var rotation_tween : Tween = create_tween()
	rotation_tween.tween_property(skin, "rotation_degrees:y", 360, tween_time).as_relative()
	rotation_tween.set_loops()
	

func _physics_process(delta: float):
	if !floorChecker.is_colliding():
		velocity.y -= (gravity * delta)
		velocity.y = clamp(velocity.y, -300, 10)

"""Possible fault"""
func _on_contact_box_body_entered(body: Node3D):
	if body is Player:
		body.treasureInHand = treasure_data
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
	#make the treasure slide off ramps and such.
