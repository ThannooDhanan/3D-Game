extends CharacterBody3D
class_name Player

enum player_state {
	IDLE,
	MOVING,
	SPRINTING,
	DIGGING,
	JUMPING
}

@export_group("Camera")
@export_range(0.0, 1.0) var mouseSensitivity := .25
@onready var cameraPivot := %"Camera Pivot"
@onready var player_cam := %playerCam

@export_group("Character Traits")
@export var speed := 8.0
@export var max_velocity : int
@export var acceleration := 12.0
@export var rotationSpeed := 10.0
@export var jumpStrength := 10.0
@export var coyote_time := .1
@onready var health := %HealthComponent
var treasureInHand : Treasure

"""Miscelaneous player status"""
@onready var player_skin := %"SnowmanSkin"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var was_on_floor := true
var camera_input_direction := Vector2.ZERO
var last_mov_direction := Vector3.FORWARD
var current_state = player_state.IDLE

"""Digging parameters"""
var canDig := false
var isDigging := false
var digTime := 0.0
const MAX_DIG_TIME := 3.0
signal finishedDigging(player: Player)

func _input(event):
	if (event.is_action_pressed("left_click")):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (event.is_action_pressed("ui_cancel")):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)
	if is_camera_motion:
		camera_input_direction = event.screen_relative * mouseSensitivity

func _physics_process(delta):
	rotateCamera(delta)
	if current_state != player_state.DIGGING:
		movePlayer(delta)
	
	if canDig and Input.is_action_pressed("Dig"):
		current_state = player_state.DIGGING
		holdDigAction(delta)
	elif current_state == player_state.DIGGING:
		resetAfterDigging(true)


func rotateCamera(delta: float):
	"""Camera rotation via mouse motion"""
	cameraPivot.rotation.x += camera_input_direction.y * delta
	cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI/6.0, PI/3.0)
	cameraPivot.rotation.y -= camera_input_direction.x * delta
	
	camera_input_direction = Vector2.ZERO

func movePlayer(delta: float):
	"""Setup for player movement"""
	var direction := Vector2.ZERO
	direction = Input.get_vector("Left","Right","Forward","Backward")
	var forward : Vector3 = player_cam.global_basis.z
	var right : Vector3 = player_cam.global_basis.x
	var verticalVelocity := velocity.y
	velocity.y = 0
	var move_direction : Vector3 = forward * direction.y + right * direction.x
	
	"""Moves player"""
	move_direction.y = 0.0
	velocity = velocity.move_toward(move_direction.normalized() * speed, acceleration * delta)
	if !is_on_floor():
		#A coyote timer make jumping mor forgiving in the game.
		if was_on_floor:
			get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
		velocity.y = verticalVelocity - (gravity * delta)
		velocity.y = clamp(velocity.y, -300, 10)
	else:
		was_on_floor = true
	
	jump()
	face_player(move_direction, delta)

func jump():
	"""Jumps"""
	var is_jumping := Input.is_action_just_pressed("jump")
	if is_jumping and ( was_on_floor):
		if treasureInHand:
			print("I have: " + treasureInHand.name)
		else:
			print("I have no treasure :(")
		velocity.y += jumpStrength
		was_on_floor = false
	move_and_slide()
	
func coyote_timeout():
	was_on_floor = false

func face_player(move_direction: Vector3, delta: float):
	"""Faces Player"""
	if move_direction.length() > 0.2:
		last_mov_direction = move_direction
	var target_angle :=  Vector3.FORWARD.signed_angle_to(last_mov_direction, Vector3.UP)
	player_skin.global_rotation.y = lerp_angle(player_skin.rotation.y, target_angle, rotationSpeed * delta)

func holdDigAction(delta: float):
	if Input.is_action_pressed("Dig"):
		#remove any velocity in the player when digging
		velocity = Vector3.ZERO
		digTime += delta

		if digTime >= MAX_DIG_TIME:
			print("finished Digging!")
			resetAfterDigging(false)
			emit_signal("finishedDigging", self)
	elif digTime > 0:
		print("Digging canceled, progress lost")
		resetAfterDigging(true)
	
func resetAfterDigging(canceled: bool):
	current_state = player_state.IDLE
	canDig = canceled
	digTime = 0.0
