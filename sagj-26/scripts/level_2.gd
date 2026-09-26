extends Node2D

@export var level_music: AudioStream

func _ready():
	MusicManager.stop_music()
	if level_music:
		MusicManager.play_music(level_music)
