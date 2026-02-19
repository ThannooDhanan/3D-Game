extends Node3D

enum TrapType {
	Floor,
	Shooting,
	Swing
}

enum TrapStatus {
	Off,
	Active
}

@export_group("Trap Properties")
@export_range(0, 100) var damage :int
@export var type : TrapType
@export var hazard_requirement :int
@export var status : TrapStatus
@export var offset : Vector3 
@export var r_offset: Vector3

@export_group("Tween Properties")
@export var tween_trans : Tween.TransitionType
@export var tween_ease : Tween.EaseType
@export var tween_time : float

@export_group("Hitting the PLayer")
@export var end_point: Marker3D 
@export var weapon : Node3D 
@export var hit_box : Area3D

var weapon_tween: Tween

func _ready():
	'''Remove when done testing'''
	TrapManagement.start_hazard_timer()
	
	TrapManagement.hazard_increased.connect(hazard_changed)
	
	hit_box.monitoring = false
	hit_box.connect("body_entered", _on_area_3d_body_entered)
	if offset:
		weapon.position = offset
	if r_offset:
		weapon.rotation_degrees = r_offset
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print(body.name, " has taken damage")
		body.health.take_damage(damage)

func hazard_changed():
	if TrapManagement.hazard >= hazard_requirement and status == TrapStatus.Off and weapon != null:
		match type:
			TrapType.Floor:
				floor_trap_activation()
			TrapType.Swing:
				swing_trap_activation()
			_:
				printerr(name, " has no valid trap type. Please set trap type in editor.")

func floor_trap_activation():
	activate_hitbox()
	weapon_tween = create_tween().set_parallel(true)
	weapon_tween.set_ease(tween_ease)
	weapon_tween.set_trans(tween_trans)
	weapon_tween.tween_property(weapon, "position", end_point.position, tween_time)
	status = TrapStatus.Active

func swing_trap_activation():
	activate_hitbox()
	weapon_tween = create_tween().set_loops()
	#Foreswing
	weapon_tween.tween_property(weapon, "rotation_degrees:z", 70.0, tween_time)
	weapon_tween.set_ease(tween_ease)
	weapon_tween.set_trans(tween_trans)
	#Backswing
	weapon_tween.tween_property(weapon, "rotation_degrees:z", -70.0, tween_time)
	weapon_tween.set_ease(tween_ease)
	weapon_tween.set_trans(tween_trans)
	pass

func activate_hitbox():
	hit_box.monitoring = true
	weapon.visible = true
