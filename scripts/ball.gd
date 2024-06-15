extends RigidBody3D

# 👇 To notify the main scene so that the playercan take the next shot
signal stopped

# There are two functions needed here

# 👇 First, an impulse must be applied to the ball 
# 👇 to start it moving. 
func shoot(angle, power):
	var force = Vector3.FORWARD.rotated(Vector3.UP, angle)
	apply_central_impulse(force * power)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# 👇 Second, when the ball stops moving, it needs to notify the 
	# 👇 main scene so that the player can take the next shot.
	if state.linear_velocity.length() < 0.1:
	# ☝️ Why 0.1? Due to floating point issues, the velocity may not 
	# ☝️ slow to 0 on its own. Its linear_velocity value may 
	# ☝️ be something like 0.00000001 for quite some time after 
	# ☝️ it appears to stop. Rather than wait, you can just stop 
	# ☝️ the ball if the speed falls below 0.1.
		stopped.emit()
		state.linear_velocity = Vector3.ZERO
	# 👇 If the ball happens to bounce over the wall and fall off the 
	# 👇 course. If this happens, you can reload the scene to let the 
	# 👇 player start over.
	if position.y < -20:
		get_tree().reload_current_scene()
