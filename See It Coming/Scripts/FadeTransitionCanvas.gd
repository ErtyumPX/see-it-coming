extends CanvasLayer

#place this scene under GameManager as a node

onready var game_manager = get_parent()

func after_fade_in():
	game_manager.after_fade_transition()
	
func after_fade_out():
	game_manager.after_fade_transition()
