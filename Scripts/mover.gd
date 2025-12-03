extends CharacterBody3D

@onready var rigidBody := $RigidBody3D

@export var speed := .4


func _process(delta):
	var direction := Vector3.ZERO
	direction = Vector3(Input.get_axis("Left","Right"), 0, Input.get_axis("Forward","Backward"))
	rigidBody.apply_impulse(direction.normalized() * speed)
	pass
