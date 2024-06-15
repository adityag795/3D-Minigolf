extends Node3D

# 👇 listing the states the game can be in
enum {AIM, SET_POWER, SHOOT, WIN}

# 👇 control the animation speed (and therefore the difficulty) by adjusting the two exported variables.
@export var power_speed = 100
@export var angle_speed = 1.1

# 👇 while the power and angle variables will be used to set their 
# 👇 respective values and change them over time
var angle_change = 1
var power = 0
var power_change = 1
var shots = 0
var state = AIM

func change_state(new_state):
	state = new_state
	match state:
		AIM:
		# 👇 placing the aiming arrow at the ball’s position and making it visible. 
			$Arrow.position = $Ball.position
			$Arrow.show()
		SET_POWER:
			power = 0
		SHOOT:
			$Arrow.hide()
			$Ball.shoot($Arrow.rotation.y, power/15)
			shots += 1
			$UI.update_shots(shots)
		WIN:
			$Ball.hide()
			$Arrow.hide()
			$UI.show_message("Win!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		# 👇 Depending on what state you are currently in, clicking it will transition to the next state.
		# 👇 For now, it just calls the function that animates the appropriate property.
		match state:
			AIM: 
				change_state(SET_POWER)
			SET_POWER:
				change_state(SHOOT)

func _process(delta: float) -> void:
	# 👇 determine what to animate based on the state. 
	match state:
		AIM:
			animate_arrow(delta)
		SET_POWER:
			animate_power(delta)
		SHOOT:
			pass

# 👇 animate_arrow(delta) and animate_power(delta) 
# 👇 are similar functions
func animate_arrow(delta):
	# 👇 Change a value between two extremes, reversing direction when the limit is reached.
	$Arrow.rotation.y += angle_speed * angle_change * delta
	# 👇 Note that the arrow is animating over a 180° range (+90° to -90°)
	if $Arrow.rotation.y > PI / 2:
		angle_change = -1
	if $Arrow.rotation.y < -PI / 2:
		angle_change = 1

func animate_power(delta):
	power += power_speed * power_change * delta
	if power >= 100:
		power_change = -1
	if power <= 0:
		power_change = 1
	$UI.update_power_bar(power)
	

# 👇 To detect when the ball drops into the hole
func _on_hole_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		print("win!")
		change_state(WIN)

func _on_ball_stopped() -> void:
	if state == SHOOT:
		change_state(AIM)
