extends CameraState
"""
Parent state for all camera based states for the Camera. Handles input based on
the mouse or the gamepad. The camera's movement depends on the active child state.
Holds shared logic between all states that move or rotate the camera.
"""


export var is_y_inverted: = true
export var fov_default: = 70.0
export var deadzone_backwards := 0.3
export var sensitivity_gamepad: = Vector2(2.5, 2.5)
export var sensitivity_mouse: = Vector2(0.1, 0.1)

var _input_relative: = Vector2.ZERO
var _is_aiming: = false


func physics_process(delta: float) -> void:
	camera_rig.global_transform.origin = camera_rig.player.global_transform.origin + camera_rig._position_start

	var look_direction: = get_look_direction()
	var move_direction: = get_move_direction()

	if _input_relative.length() > 0:
		update_rotation(_input_relative * sensitivity_mouse * delta)
		_input_relative = Vector2.ZERO
	elif look_direction.length() > 0:
		update_rotation(look_direction * sensitivity_gamepad * delta)

	var is_moving_towards_camera: bool = (
		move_direction.x >= -deadzone_backwards and move_direction.x <= deadzone_backwards
	)
	if not (is_moving_towards_camera or _is_aiming):
		auto_rotate(move_direction)

	camera_rig.rotation.y = wrapf(camera_rig.rotation.y, -PI, PI)


func auto_rotate(move_direction: Vector3) -> void:
	var offset: float = camera_rig.player.rotation.y - camera_rig.rotation.y
	var target_angle: float = (
		camera_rig.player.rotation.y - 2 * PI if offset > PI
		else camera_rig.player.rotation.y + 2 * PI if offset < -PI
		else camera_rig.player.rotation.y
	)
	camera_rig.rotation.y = lerp(camera_rig.rotation.y, target_angle, 0.015)


func unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_input_relative += event.get_relative()


func update_rotation(offset: Vector2) -> void:
	camera_rig.rotation.y -= offset.x
	camera_rig.rotation.x -= offset.y * -1.0 if is_y_inverted else offset.y
	camera_rig.rotation.x = clamp(camera_rig.rotation.x, -0.75, 1.25)
	camera_rig.rotation.z = 0


"""
Returns the direction of the camera movement from the player
"""
static func get_look_direction() -> Vector2:
	return Vector2(
			Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
			Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		).normalized()


"""
Returns the move direction of the character controlled by the player
"""
static func get_move_direction() -> Vector3:
	return Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_front")
	)
