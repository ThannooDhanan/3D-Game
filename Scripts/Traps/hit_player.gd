extends RigidBody3D

var damage : int
var active := true
@export var speed : float = 5.0

func _ready():
	if ! visibility_changed.is_connected(return_to_shooter):
		visibility_changed.connect(return_to_shooter)
	if is_visible() and active:
		linear_velocity = Vector3.BACK * speed

func _on_area_3d_body_entered(body: Node3D):
	if body is Player:
		body.health.take_damage(damage)
		visible = false

func return_to_shooter():
	process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)
	visible = false
	active = false
