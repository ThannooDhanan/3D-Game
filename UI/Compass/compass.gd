extends Control
class_name Compass

@export var player_UI : Player_UI
@export var needle : Control
@export_range(1.0, 10.0) var idle_rotation : float = 5.0
@export var compass_glo : Control
@export_range(5.0, 100.0) var pulse_radius : float = 10
var pulse_time := 0.0
var waypoints : Waypoint_and_Home

func _process(delta: float) -> void:
	if player_UI == null:
		rotate_pointer(delta)
	else:
		waypoints = player_UI.player.waypoints
		if player_UI.player.canCashout:
			pass
		else:
			update_direction()
		proximity_glo(delta)
		
func rotate_pointer(delta: float):
	needle.rotation += idle_rotation * delta

func update_direction():
	var point = waypoints.activeDigSpot
	var dig_spot_pos : Vector2 = Vector2(point.global_position.z, point.global_position.x)
	var player_cam : Node3D = player_UI.player.cameraPivot
	var cam_rot_vect : Vector2 = Vector2(cos(player_cam.global_rotation.y),sin(player_cam.global_rotation.y))
	var player_pos : Vector2 =  Vector2(player_UI.player.global_position.z, player_UI.player.global_position.x)
	var point_to := dig_spot_pos.direction_to(player_pos)
	var angle_between := point_to.angle_to(cam_rot_vect)
	
	needle.rotation = lerp_angle(needle.rotation, angle_between, 0.15)
	
func proximity_glo(delta: float):
	var player_dist := player_UI.player.global_position.distance_to(waypoints.activeDigSpot.global_position)
	if player_dist < pulse_radius:
		var pulse_speed :=  remap(player_dist, 0, pulse_radius, 4.0, 0.5)
		pulse_time += delta * pulse_speed
		var pulse_scale := 1 + 0.12 * (sin(pulse_time * TAU))
		compass_glo.scale = Vector2(pulse_scale, pulse_scale)
	else:
		compass_glo.scale = Vector2.ZERO
		pulse_time = 0.0
