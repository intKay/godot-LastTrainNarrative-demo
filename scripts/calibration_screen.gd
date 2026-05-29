extends Control

@onready var title_label: Label = $RootMargin/VBox/TitleLabel
@onready var instruction_label: Label = $RootMargin/VBox/InstructionLabel
@onready var question_label: Label = $RootMargin/VBox/QuestionLabel
@onready var buttons_vbox: VBoxContainer = $RootMargin/VBox/ButtonsVBox
@onready var status_label: Label = $RootMargin/VBox/StatusLabel

var options_data: Array = [
	{"hint": "light", "label": "灯", "text": "A. 一盏整夜没有熄灭的灯"},
	{"hint": "door", "label": "门", "text": "B. 一扇始终没有打开的门"},
	{"hint": "broadcast", "label": "广播", "text": "C. 一段无人回应的广播"},
	{"hint": "ticket", "label": "车票", "text": "D. 一张写错日期的车票"},
]


func _ready() -> void:
	status_label.hide()
	_create_buttons()


func _create_buttons() -> void:
	for opt in options_data:
		var btn := Button.new()
		btn.text = opt.text
		var hint: String = opt.hint
		var label: String = opt.label
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
