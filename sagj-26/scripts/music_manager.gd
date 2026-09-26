extends Node

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func play_music(stream: AudioStream):
	if not stream:
		return
		
	if audio_player.stream == stream and audio_player.playing:
		return
		
	audio_player.stream = stream
	audio_player.play()

func stop_music():
	if audio_player:
		audio_player.stop()
