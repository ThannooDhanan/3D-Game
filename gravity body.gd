extends RigidBody3D

func _integrate_forces(state):
	state.apply_central_gravity
