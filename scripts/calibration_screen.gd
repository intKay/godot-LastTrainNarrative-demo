extends Control

@onready var title_label: Label = $RootMargin/VBox/TitleLabel
@onready var instruction_label: Label = $RootMargin/VBox/InstructionLabel
@onready var question_label: Label = $RootMargin/VBox/QuestionLabel
@onready var buttons_vbox: VBoxContainer = $RootMargin/VBox/ButtonsVBox
@onready var status_label: Label = $RootMargin/VBox/StatusLabel

var questions_data: Array = []
var current_question_index: int = 0
var current_options: Array = []


func _ready() -> void:
	status_label.hide()
	_load_data()


func _load_data() -> void:
	var data = DataLoader.load_json("res://data/calibration_questions.json")
	if data and data.size() > 0:
		questions_data = data
		_display_question(0)


func _display_question(index: int) -> void:
	_clear_buttons()
	var q = questions_data[index]
	question_label.text = q.prompt
	current_options = q.options
	_create_buttons()
	_enable_all_buttons()
	title_label.show()
	instruction_label.show()
	question_label.show()
	status_label.hide()


func _clear_buttons() -> void:
	for child in buttons_vbox.get_children():
		if child is Button:
			child.queue_free()


func _create_buttons() -> void:
	for i in range(current_options.size()):
		var opt = current_options[i]
		var btn := Button.new()
		btn.text = opt.text
		btn.pressed.connect(_on_option_selected.bind(i))
		buttons_vbox.add_child(btn)


func _enable_all_buttons() -> void:
	for child in buttons_vbox.get_children():
		if child is Button:
			child.disabled = false


func _on_option_selected(index: int) -> void:
	var opt = current_options[index]

	var delta = opt.get("state_delta", {})
	GameState.doubt += delta.get("doubt", 0)
	GameState.control += delta.get("control", 0)
	GameState.obedience += delta.get("obedience", 0)
	GameState.anomaly += delta.get("anomaly", 0)

	var flags = opt.get("set_flags", [])
	for f in flags:
		GameState.flags[f] = true

	GameState.choice_history.append(opt.get("last_choice_label", ""))
	GameState.last_choice_label = opt.get("last_choice_label", "")

	if opt.has("initial_world_hint"):
		GameState.initial_world_hint = opt.initial_world_hint

	for child in buttons_vbox.get_children():
		if child is Button:
			child.disabled = true

	current_question_index += 1
	if current_question_index < questions_data.size():
		await get_tree().create_timer(0.5).timeout
		_display_question(current_question_index)
	else:
		_finish_calibration()


func _finish_calibration() -> void:
	title_label.hide()
	instruction_label.hide()
	question_label.hide()
	status_label.show()
	status_label.text = "校准完成。\n正在生成场景……\n场景确认：末班车站。"
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/station_scene.tscn")
