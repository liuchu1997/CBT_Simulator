extends CharacterBody2D

@export var move_speed: float = 128.0
@export var tile_size: int = 16

var is_moving: bool = false
var input_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var facing: String = "down"
var is_frozen: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_ray: RayCast2D = $InteractRay

func _ready():
	sprite.play("idle_down")
	interact_ray.enabled = true
	_update_raycast_direction()
	DialogueManager.dialogue_started.connect(func(): is_frozen = true)
	DialogueManager.dialogue_finished.connect(func(): is_frozen = false)

func _physics_process(_delta: float):
	if is_frozen:
		velocity = Vector2.ZERO
		return
	if is_moving:
		_move_to_target()
	else:
		_get_input()

func _get_input():
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2.UP
		facing = "up"
	elif Input.is_action_pressed("move_down"):
		dir = Vector2.DOWN
		facing = "down"
	elif Input.is_action_pressed("move_left"):
		dir = Vector2.LEFT
		facing = "left"
	elif Input.is_action_pressed("move_right"):
		dir = Vector2.RIGHT
		facing = "right"
	
	if dir != Vector2.ZERO:
		interact_ray.target_position = dir * tile_size
		interact_ray.force_raycast_update()
		
		if not interact_ray.is_colliding():
			is_moving = true
			target_position = global_position + dir * tile_size
			sprite.play("walk_" + facing)
		else:
			sprite.play("idle_" + facing)

func _move_to_target():
	var to_target := target_position - global_position
	var distance := to_target.length()
	var step := move_speed * get_physics_process_delta_time()
	
	if distance <= step:
		global_position = target_position
		is_moving = false
		velocity = Vector2.ZERO
		sprite.play("idle_" + facing)
		return
	
	velocity = to_target.normalized() * move_speed
	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		_handle_interact()
	elif event.is_action_pressed("profile"):
		if not is_frozen and not DialogueManager.is_active():
			get_tree().call_group("ui", "toggle_patient_profile")

func _handle_interact():
	if is_frozen or DialogueManager.is_active() or DialogueManager.is_on_cooldown():
		return
	_update_raycast_direction()
	interact_ray.force_raycast_update()
	if interact_ray.is_colliding():
		var collider := interact_ray.get_collider()
		if collider.has_method("on_interact"):
			collider.on_interact()

func _update_raycast_direction():
	var dir_map := {
		"up": Vector2.UP,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
		"right": Vector2.RIGHT,
	}
	var dir: Vector2 = dir_map.get(facing, Vector2.DOWN)
	interact_ray.target_position = dir * tile_size
