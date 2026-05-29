extends Control

@onready var title_label: Label = $RootMargin/VBox/TitleLabel
@onready var system_label: Label = $RootMargin/VBox/SystemLabel
@onready var body_label: Label = $RootMargin/VBox/BodyLabel
@onready var restart_btn: Button = $RootMargin/VBox/RestartButton

var endings_data: Array = []


func _ready() -> void:
	restart_btn.pressed.connect(_on_restart)
	_load_endings()
	_show_ending()


func _load_endings() -> void:
	endings_data = DataLoader.load_json("res://data/endings.json")
	if endings_data == null:
		push_error("endings.json 读取失败")


func _get_ending_id() -> String:
	var d = GameState.doubt
	var c = GameState.control
	var o = GameState.obedience
	var a = GameState.anomaly

	if o > d and o > c:
		return "obedience_ending"
	elif c > d and c > o:
		return "control_ending"
	elif d > c and d > o:
		return "doubt_ending"

	if a > 0:
		return "doubt_ending"
	return "doubt_ending"


func _show_ending() -> void:
	var ending_id = _get_ending_id()
	for e in endings_data:
		if e.ending_id == ending_id:
			title_label.text = e.title
			system_label.text = e.system_label
			body_label.text = "\n".join(e.body)
			return
	push_error("结局数据未找到: " + ending_id)


func _on_restart() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/calibration_screen.tscn")
