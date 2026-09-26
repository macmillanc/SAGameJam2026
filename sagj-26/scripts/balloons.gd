class_name HotAirBalloon
extends Sprite2D

@export_category("Floating Settings")
@export var bob_amplitude: float = 15.0  # How far up and down it moves
@export var bob_frequency: float = 2.0   # How fast it bobs
@export var sway_amplitude: float = 0.02 # Subtle rotation tilt

@export_category("Season & Transition Settings")
@export var spring_season_index: int = 0  # 0 is Spring
@export var fly_away_speed: float = 600.0 # How fast it shoots up off-screen

var start_position: Vector2
var prev_season: int = -1
var is_flying_away: bool = false


func _ready() -> void:
	# Save the balloon's initial starting position in the world
	start_position = position
	prev_season = Global.season
	
	# Set initial visibility based on starting season
	visible = (Global.season == spring_season_index)


func _process(delta: float) -> void:
	# Detect if the season has changed this frame
	if Global.season != prev_season:
		if prev_season == spring_season_index and Global.season != spring_season_index:
			# Season changed AWAY from Spring: start flying away!
			is_flying_away = true
		elif Global.season == spring_season_index:
			# Season changed BACK to Spring: reset position and show
			position = start_position
			visible = true
			is_flying_away = false
			
		prev_season = Global.season

	# Handle the fast fly-away animation
	if is_flying_away:
		position.y -= fly_away_speed * delta * 2
		
		# Once it's far enough off-screen, disappear and stop moving
		if position.y < start_position.y - 800.0:
			visible = false
			is_flying_away = false
		return

	# Standard behavior when it's not Spring
	var is_spring: bool = (Global.season == spring_season_index)
	if not is_spring:
		visible = false
		return

	# Normal Spring bobbing behavior
	visible = true
	var time = Time.get_ticks_msec() / 1000.0
	
	var y_offset = sin(time * bob_frequency) * bob_amplitude
	position.y = start_position.y + y_offset
	
	rotation = sin(time * (bob_frequency * 0.5)) * sway_amplitude
