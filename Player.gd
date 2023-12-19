extends KinematicBody2D

signal enemy_collided

const MAX_SPEED = 160

const GRAVITY   = 700
const ACCEL     = 150
const FRICTION  = 500

var velocity = Vector2.ZERO
var original_position: Vector2

var player_colors = [
	Color(1, 1, 1, 1),		# normal
	Color(1, 0.5, 0.5, 1),	# red
	Color(0.5, 0.5, 1, 1)		# blue
]

var player_sizes = [
	Vector2.ONE,		# 1x scale
	Vector2(2.0, 2.0),	# 2x scale
	Vector2(0.5, 0.5)	# 0.5x scale
]

var player_jumps = [
	250,
	150,
	350,
]

var player_attacks = [
	'attack1',
	'attack2',
	'attack3'
]

var player_airattacks = [
	'airattack1',
	'airattack2'
]

var c_transform = 0
var c_player_color = Color(1, 1, 1, 1)
var c_player_size  = Vector2.ONE
var c_attack = 0
var c_airattack = 0

var sword_hitbox_original = null

var transforming = false
var attacking = false
var airattacking = false

onready var anim = $AnimatedSprite
onready var tween = $Tween
onready var s_hitbox_cs = $SwordHitbox/CollisionShape2D

func _ready():
	anim.play("idle")
	
	c_player_color = modulate
	c_player_size  = scale 
	
	sword_hitbox_original = s_hitbox_cs.position.x
	
	original_position = position
	
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = move_toward(velocity.x, MAX_SPEED, ACCEL * delta)
		if not attacking and not airattacking:
			anim.play("run")
		anim.flip_h = false
		s_hitbox_cs.position.x = sword_hitbox_original
	elif Input.is_action_pressed("ui_left"):
		velocity.x = move_toward(velocity.x, -MAX_SPEED, ACCEL * delta)
		if not attacking and not airattacking:
			anim.play("run")
		anim.flip_h = true
		s_hitbox_cs.position.x = -sword_hitbox_original
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		if anim.animation == "idle" or anim.animation == "kneel":
			if Input.is_action_just_pressed("transform") and not transforming:
				transforming = true
				anim.play("kneel")

				$TransformTimer.start()
				
				tween.interpolate_property(
					self, "modulate", c_player_color, 
					player_colors[(c_transform + 1) % len(player_colors)], 2.5, Tween.TRANS_LINEAR)
					
				tween.interpolate_property(
					self, "scale", c_player_size, 
					player_sizes[(c_transform + 1) % len(player_sizes)], 2.5, Tween.TRANS_LINEAR)
					
				tween.start()
				
		else:
			if anim.animation != "unkneel" or (not anim.playing and anim.animation == "unkneel"):
				if not attacking and not airattacking:
					anim.play("idle")
			
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_select")) \
			and is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -player_jumps[c_transform % len(player_sizes)]
			attacking = false
		else:
			c_attack += 1
			anim.play(player_attacks[c_attack % len(player_attacks)])
			attacking = true
			
	if transforming and (
		Input.is_action_just_pressed("ui_up") or	\
		Input.is_action_just_pressed("ui_right") or	\
		Input.is_action_just_pressed("ui_left") or	\
		Input.is_action_just_pressed("ui_select")):
			transforming = false
			tween.stop(self)
			$TransformTimer.stop()
			modulate = c_player_color
			scale = c_player_size
		
	if not is_on_floor():
		if Input.is_action_just_pressed("ui_select"):
			c_airattack += 1
			anim.play(player_airattacks[c_airattack % len(player_airattacks)])
			airattacking = true
		elif not airattacking:
			anim.play("jump")
			
	if attacking or airattacking:
		$SwordHitbox/CollisionShape2D.disabled = false
	else:
		$SwordHitbox/CollisionShape2D.disabled = true

func get_transform():
	return c_transform % 3

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_TransformTimer_timeout():
	print("-------------")
	print("Current Transform: ", c_transform)
	print("Current Color: ", c_player_color)
	print("Current Size: ", c_player_size)
	
	transforming = false
	c_transform += 1
	
	c_player_color = player_colors[c_transform % len(player_colors)]
	modulate = c_player_color
	
	c_player_size = player_sizes[c_transform % len(player_sizes)]
	scale = c_player_size
	
	tween.reset_all()
	
	anim.play("unkneel")
	
func _on_Tween_tween_completed(object, key):
	pass

func _on_AnimatedSprite_animation_finished():
	if anim.animation == "unkneel":
		anim.play("idle")
		
	if anim.animation in player_attacks:
		attacking = false

	if anim.animation in player_airattacks:
		airattacking = false

func reset_player():
	position = original_position
	
func enemy_killed():
	pass
	
func enemy_collided():
	emit_signal("enemy_collided")
