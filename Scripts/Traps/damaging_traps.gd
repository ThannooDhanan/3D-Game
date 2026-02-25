extends Node3D

enum TrapType {
	Floor,
	Shooting,
	Swing,
	Platform
}

@export_group("Trap Properties")
@export var type : TrapType
@export var offset : Vector3 
@export var r_offset: Vector3
@export_subgroup("Trap Statuses")
@export var trap_active: bool =  false
@export var perm_disable: bool = false
@export_subgroup("Hazard Requirements")
@export_range(0, 100) var min_hazard_required : int
@export_range(0, 100) var max_hazard_required :int

@export_group("Tween Properties")
@export var tween_trans : Tween.TransitionType
@export var tween_ease : Tween.EaseType
@export var tween_time : float

@export_group("Hitting the PLayer")
@export_range(0, 100) var damage :int
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
	if calculate_activation_chance() \
			and !trap_active \
			and !perm_disable \
			and weapon != null:
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

func swing_trap_activation():
	activate_hitbox()
	weapon_tween = create_tween().set_loops()
	weapon_tween.set_ease(tween_ease)
	weapon_tween.set_trans(tween_trans)

	#Foreswing
	weapon_tween.tween_property(weapon, "rotation_degrees", -r_offset, tween_time)
	#Backswing
	weapon_tween.tween_property(weapon, "rotation_degrees", r_offset, tween_time)
	weapon_tween.loop_finished.connect(finished_loop)

func activate_hitbox():
	hit_box.monitoring = true
	weapon.visible = true
	trap_active = true

func finished_loop(_loop_Index: int):
	if perm_disable:
		weapon_tween.stop()
		hit_box.monitoring = false
		trap_active = false

func calculate_activation_chance() -> bool:
	var activate: bool
	var power_scale := 1.2
	if TrapManagement.hazard < min_hazard_required:
		activate = false
	elif TrapManagement.hazard >= max_hazard_required:
		activate = true
	else:
		var normalized : float = (float(TrapManagement.hazard) - min_hazard_required)/(max_hazard_required - min_hazard_required)
		normalized = clamp(normalized, 0.0, 1.0)
		var chance = normalized ** power_scale
		if randf() <= chance:
			activate = true
		else:
			activate = false
	
	return activate
