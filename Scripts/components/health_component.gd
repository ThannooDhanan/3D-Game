extends Node3D
class_name HealthComponent
"""
This component will serve as the health for anything that uses health,
"""

@export var health := 5
#Custom signal incase something occurs on death (like a death bomb)
signal destroyed

#damage function can also serve as healing with negative numbers passed
func take_damage(damage : int): 
	health -= damage
	if health <= 0:
		die()

func die():
	destroyed.emit()
