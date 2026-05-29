extends Control

enum Phase { INTRO, INVESTIGATED, FINISHED }
var phase: int = Phase.INTRO

var round_options: Array = []
var notice_board_data: Dictionary = {}

@onready var notice_btn: Button = $RootMargin/VBox/StationHBox/NoticeBoardButton
@onready var broadcast_light: ColorRect = $RootMargin/VBox/StationHBox/BroadcastLight
@onready var story_label: Label = $RootMargin/VBox/StoryLabel
@onready var choice_a: Button = $RootMargin/VBox/ChoiceAButton
@onready var choice_b: Button = $RootMargin/VBox/ChoiceBButton
@onready var choice_c: Button = $RootMargin/VBox/ChoiceCButton
@onready var choice_d: Button = $RootMargin/VBox/ChoiceDButton


func _ready() -> void:
	_load_data()
	_hide_choices()
	notice_btn.pressed.connect(_on_notice_board)
	choice_a.pressed.connect(_on_choice_a)
	choice_b.pressed.connect(_on_choice_b)
	choice_c.pressed.connect(_on_choice_c)
	choice_d.pressed.connect(_on_choice_d)


func _load_data() -> void:
	var story_data = DataLoader.load_json("res://data/story_nodes.json")
	if story_data and story_data.size() > 0:
		for node in story_data:
			if node.node_id == "station_intro":
				story_label.text = node.visible_text
			elif node.node_id == "station_round_1":
				round_options = node.options

	var interact_data = DataLoader.load_json("res://data/interactables.json")
	if interact_data and interact_data.size() > 0:
		for obj in interact_data:
			if obj.object_id == "notice_board":
				notice_board_data = obj


func _apply_state_delta(delta: Dictionary) -> void:
	if delta.has("doubt"):
		GameState.doubt += delta.doubt
	if delta.has("control"):
		GameState.control += delta.control
	if delta.has("obedience"):
		GameState.obedience += delta.obedience
	if delta.has("anomaly"):
		GameState.anomaly += delta.anomaly


func _make_choice(index: int) -> void:
	if index < 0 or index >= round_options.size():
		return
	var opt = round_options[index]
	_apply_state_delta(opt.state_delta)
	GameState.last_choice_label = opt.last_choice_label
	GameState.choice_history.append(opt.last_choice_label)
	GameState.current_stage = 1
	story_label.text = opt.feedback_text
	_disable_choices()
	var c = opt.broadcast_light_color
	_update_broadcast_light(Color(c[0], c[1], c[2]))
	phase = Phase.FINISHED


func _hide_choices() -> void:
	choice_a.hide()
	choice_b.hide()
	choice_c.hide()
	choice_d.hide()


func _show_choices() -> void:
	choice_a.show()
	choice_b.show()
	choice_c.show()
	choice_d.show()


func _on_notice_board() -> void:
	if phase == Phase.INTRO:
		var hint: String = GameState.initial_world_hint
		var texts: Dictionary = notice_board_data.get("texts_by_hint", {})
		var text: String = texts.get(hint, "电子公告屏显示：末班车即将进站。")
		story_label.text = text
		_show_choices()
		phase = Phase.INVESTIGATED
	elif phase == Phase.INVESTIGATED:
		story_label.text = notice_board_data.get("investigated_text", "公告屏依旧亮着。\n你已浏览过公告屏。")
	elif phase == Phase.FINISHED:
		var label: String = GameState.last_choice_label
		var template: String = notice_board_data.get("echo_text_template", "电子公告屏显示：23:47  末班车\n目的地：校准中\n上一行为：%s")
		story_label.text = template % label


func _disable_choices() -> void:
	choice_a.disabled = true
	choice_b.disabled = true
	choice_c.disabled = true
	choice_d.disabled = true


func _update_broadcast_light(color: Color) -> void:
	broadcast_light.color = color


func _on_choice_a() -> void:
	_make_choice(0)


func _on_choice_b() -> void:
	_make_choice(1)


func _on_choice_c() -> void:
	_make_choice(2)


func _on_choice_d() -> void:
	_make_choice(3)
