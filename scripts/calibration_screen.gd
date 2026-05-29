extends Control

@onready var title_label: Label = $RootMargin/VBox/TitleLabel
@onready var instruction_label: Label = $RootMargin/VBox/InstructionLabel
@onready var question_label: Label = $RootMargin/VBox/QuestionLabel
@onready var buttons_vbox: VBoxContainer = $RootMargin/VBox/ButtonsVBox
@onready var status_label: Label = $RootMargin/VBox/StatusLabel

var options_data: Array = []


func _ready() -> void:
	status_label.hide()
	_load_data()
	_create_buttons()


func _load_data() -> void:
	var data = DataLoader.load_json("res://data/calibration_questions.json")
	if data and data.size() > 0:
		var q = data[0]
		question_label.text = q.prompt
		options_data = q.options


func _create_buttons() -> void:
	for opt in options_data:
		var btn := Button.new()
		btn.text = opt.text
		var hint: String = opt.initial_world_hint
		var label: String = opt.last_choice_label
		btn.pressed.connect(_on_option_selected.bind(hint, label, btn))
		buttons_vbox.add_child(btn)


func _on_option_selected(hint: String, label: String, _btn: Button) -> void:
	GameState.initial_world_hint = hint
	GameState.last_choice_label = label
	GameState.choice_history.append(label)

	for child in buttons_vbox.get_children():
		if child is Button:
			child.disabled = true

	title_label.hide()
	instruction_label.hide()
	question_label.hide()
	status_label.show()
	status_label.text = "校准完成。\n正在生成场景……\n场景确认：末班车站。"
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/station_scene.tscn")
