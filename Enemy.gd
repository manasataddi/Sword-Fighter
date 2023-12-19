extends KinematicBody2D

signal enemy_collidated

export var direction = -1
export var detects_cliffs = true
export var default_speed = 50

export var can_be_killed_by_0 = true
export var can_be_killed_by_1 = true
export var can_be_killed_by_2 = false

var velocity = Vector2()
const GRAVITY = 40
var speed = default_speed

const DEATH_TIMER_LIMIT = 8
var death_timer_current = 0

var current_scale
var new_scale
var player

var original_position: Vector2

func _ready():
	$AnimatedSprite.flip_h = direction > 0
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$FloorDetector.enabled = detects_cliffs
	
	original_position = position
	original_position.y += 20
	
func _physics_process(delta):
	velocity.y += GRAVITY
	velocity.x = speed * direction
	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_wall() or (not $FloorDetector.is_colliding() and detects_cliffs and is_on_floor()):
		direction *= -1
		$AnimatedSprite.flip_h = direction > 0
		$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction

func hide_enemy():
	speed = 0
	
	$Hurtbox.set_collision_layer_bit(2, false)
	$Hurtbox.set_collision_mask_bit(0, false)
	
	$Hitbox.set_collision_layer_bit(2, false)
	$Hitbox.set_collision_mask_bit(0, false)
	
	set_collision_layer_bit(2, false)
	set_collision_mask_bit(0, false)
	
	hide()
	
func show_enemy():
	speed = default_speed
	death_timer_current = 0
	
	$DeathTimer.stop()
	
	$Hurtbox.set_collision_layer_bit(2, true)
	$Hurtbox.set_collision_mask_bit(0, true)
	
	$Hitbox.set_collision_layer_bit(2, true)
	$Hitbox.set_collision_mask_bit(0, true)
	
	set_collision_layer_bit(2, true)
	set_collision_mask_bit(0, true)
	set_collision_mask_bit(1, true)
	
	position = original_position
	
	$AnimatedSprite.play("move")
	$AnimatedSprite.flip_h = direction > 0
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$FloorDetector.enabled = detects_cliffs
	
	show()

func _on_DeathTimer_timeout():
	death_timer_current += 1
	
	if death_timer_current > DEATH_TIMER_LIMIT:
		hide()
	else:
		$DeathTimer.start()

func _on_Hitbox_body_entered(body):
	if not body is TileMap:
		#$Hitbox.set_collision_layer_bit(2, false)
		#$Hitbox.set_collision_mask_bit(0, false)
		
		body.enemy_collided()
		
func _on_Hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if "SwordHitbox" in str(area):
		player = area.get_owner()
		
		var player_transform = player.get_transform()
		
		if not ((player_transform == 0 and can_be_killed_by_0) or \
				(player_transform == 1 and can_be_killed_by_1) or \
				(player_transform == 2 and can_be_killed_by_2)):
			return
		
		$AnimatedSprite.play("die")
		speed = 0
		
		$Hurtbox.set_collision_layer_bit(2, false)
		$Hurtbox.set_collision_mask_bit(0, false)
		
		$Hitbox.set_collision_layer_bit(2, false)
		$Hitbox.set_collision_mask_bit(0, false)
		
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(0, false)
		
		player.enemy_killed()
		
		$DeathTimer.start()
