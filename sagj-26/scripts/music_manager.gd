extends Node

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Pitch coming from the current season
var season_pitch: float = 1.0

# Pitch coming from slow/speed time effects
var speed_pitch: float = 1.0


func play_music(stream: AudioStream):
	if not stream:
		return
	
	if audio_player.stream == stream and audio_player.playing:
		return
	
	audio_player.stream = stream
	audio_player.pitch_scale = season_pitch * speed_pitch
	audio_player.play()


func stop_music():
	if audio_player:
		audio_player.stop()


# Changes the pitch caused by the season.
# This is smoothly tweened during the season transition.
func twist_pitch(target_pitch: float, duration: float = 2.0):
	if not audio_player:
		return
	
	season_pitch = target_pitch
	
	var target_total_pitch = season_pitch * speed_pitch
	
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	
	tween.tween_property(
		audio_player,
		"pitch_scale",
		target_total_pitch,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Changes the pitch caused by slow/speed time effects.
func set_game_speed_pitch(multiplier: float):
	if not audio_player:
		return
	
	speed_pitch = multiplier
	
	audio_player.pitch_scale = season_pitch * speed_pitch
