extends Node

var current_stage: int = 0
var current_node_id: String = ""
var doubt: int = 0
var control: int = 0
var obedience: int = 0
var anomaly: int = 0
var flags: Dictionary = {}
var choice_history: Array = []
var initial_world_hint: String = ""
var last_choice_label: String = ""


func reset() -> void:
	current_stage = 0
	current_node_id = ""
	doubt = 0
	control = 0
	obedience = 0
	anomaly = 0
	flags = {}
	choice_history = []
	initial_world_hint = ""
	last_choice_label = ""
