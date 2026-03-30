extends RigidBody3D
class_name Projectile

var damage : int 
var active := false 
@export var speed : float = 5.0 
@export var lifetime : float 
@export var lifeTimer : Timer 
var pool

func _ready(): 
	if is_visible() and active: 
		linear_velocity = self.global_rotation * speed
	if !lifeTimer == null: 
		lifeTimer.connect("timeout", go_back)

func _on_area_3d_body_entered(body: Node3D):
	if body is Player:
		body.health.take_damage(damage)
		visible = false 
	pool.return_to_pool(self)

func return_to_shooter():
	process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)
	visible = false
	active = false

func disable_projectile():
	global_position = Vector3.ZERO
	active = false
	visible = false
	freeze = true
	process_mode = Node.PROCESS_MODE_DISABLED

func go_back(): 
	if active:
		pool.return_to_pool(self)

func activate_timer(): 
	lifeTimer.start(lifetime)
	if !lifeTimer.timeout.is_connected(go_back):
		lifeTimer.timeout.connect(go_back)
