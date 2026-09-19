class_name StateMachine 
extends Node

@export var initial_state: State
var current_state: State

func _ready():
	# Pass the player reference to all child states
	for child in get_children():
		if child is State:
			child.player = owner # 'owner' refers to the root Player node
			child.state_machine = self
			
	if initial_state:
		current_state = initial_state
		current_state.enter()

func physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func transition_to(new_state_name: String):
	var new_state = get_node(new_state_name)
	if new_state == current_state:
		return
		
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()
