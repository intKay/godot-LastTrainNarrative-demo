extends Control

enum Phase { INTRO, INVESTIGATED, FINISHED, END }
var phase: int = Phase.INTRO

var story_data: Array = []
var round_options: Array = []
var notice_board_data: Dictionary = {}
var interactables_data: Dictionary = {}
var current_round_id: String = "station_round_1"
var next_round_id: String = ""
var has_next_round: bool = false
var interactable_stage_id: String = "station_round_1"
var text_tween: Tween

@onready var notice_btn: Button = $RootMargin/VBox/StationHBox/NoticeBoardButton
@onready var broadcast_light: ColorRect = $RootMargin/VBox/StationHBox/BroadcastLight
@onready var story_label: Label = $RootMargin/VBox/StoryLabel
@onready var choice_a: Button = $RootMargin/VBox/ChoiceAButton
@onready var choice_b: Button = $RootMargin/VBox/ChoiceBButton
@onready var choice_c: Button = $RootMargin/VBox/ChoiceCButton
@onready var choice_d: Button = $RootMargin/VBox/ChoiceDButton
@onready var clock_btn: Button = $RootMargin/VBox/InteractHBox/ClockButton
@onready var broadcast_light_btn: Button = $RootMargin/VBox/InteractHBox/BroadcastLightButton
@onready var exit_gate_btn: Button = $RootMargin/VBox/InteractHBox/ExitGateButton


func _ready() -> void:
	_load_data()
	_hide_choices()
	notice_btn.pressed.connect(_on_notice_board)
	choice_a.pressed.connect(_on_choice_a)
	choice_b.pressed.connect(_on_choice_b)
	choice_c.pressed.connect(_on_choice_c)
	choice_d.pressed.connect(_on_choice_d)
	clock_btn.pressed.connect(_on_clock)
	broadcast_light_btn.pressed.connect(_on_broadcast_light)
	exit_gate_btn.pressed.connect(_on_exit_gate)


func _load_data() -> void:
	story_data = DataLoader.load_json("res://data/story_nodes.json")
	if story_data and story_data.size() > 0:
		for node in story_data:
			if node.node_id == "station_intro":
				story_label.text = node.visible_text

	_load_round_data("station_round_1")

	var interact_data = DataLoader.load_json("res://data/interactables.json")
	if interact_data and interact_data.size() > 0:
		for obj in interact_data:
			interactables_data[obj.object_id] = obj
			if obj.object_id == "notice_board":
				notice_board_data = obj


func _load_round_data(round_id: String) -> void:
	current_round_id = round_id
	interactable_stage_id = round_id
	round_options = []
	has_next_round = false
	for node in story_data:
		if node.node_id == round_id:
			if node.has("visible_text"):
				story_label.text = node.visible_text
				_flash_story_label()
			if node.has("options"):
				round_options = node.options
				for opt in node.options:
					if opt.has("next_node") and opt.next_node != "":
						has_next_round = true
						break
	_hide_choices()
	_update_broadcast_light(Color(0.3, 0.3, 0.3))
	phase = Phase.INTRO


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
	GameState.current_stage += 1
	story_label.text = opt.feedback_text
	_disable_choices()
	var c = opt.broadcast_light_color
	_update_broadcast_light(Color(c[0], c[1], c[2]))

	next_round_id = opt.get("next_node", "")
	if next_round_id != "":
		interactable_stage_id = next_round_id
		_show_continue()
	phase = Phase.FINISHED


func _show_continue() -> void:
	choice_a.text = "继续"
	choice_b.hide()
	choice_c.hide()
	choice_d.hide()
	choice_a.disabled = false
	if choice_a.pressed.is_connected(_on_choice_a):
		choice_a.pressed.disconnect(_on_choice_a)
	if not choice_a.pressed.is_connected(_on_continue):
		choice_a.pressed.connect(_on_continue)


func _on_continue() -> void:
	if choice_a.pressed.is_connected(_on_continue):
		choice_a.pressed.disconnect(_on_continue)
	if not choice_a.pressed.is_connected(_on_choice_a):
		choice_a.pressed.connect(_on_choice_a)

	var target_id: String = next_round_id if next_round_id != "" else "station_round_2"
	_load_round_data(target_id)

	for i in range(round_options.size()):
		var btn: Button = [choice_a, choice_b, choice_c, choice_d][i]
		btn.text = round_options[i].text
		btn.disabled = false
		btn.show()

	phase = Phase.INVESTIGATED


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
		if not has_next_round:
			story_label.text = notice_board_data.get("three_rounds_end_text", "当前版本已记录三次主线行为。\n下一阶段将根据状态生成结局判断。")
			phase = Phase.END
		else:
			var template: String = notice_board_data.get("echo_text_template", "电子公告屏显示：23:47  末班车\n目的地：校准中\n上一行为：%s")
			story_label.text = template % label
	elif phase == Phase.END:
		var label: String = GameState.last_choice_label
		var template: String = notice_board_data.get("echo_text_final", "电子公告屏显示：23:47  末班车\n目的地：等待最终判断\n上一行为：%s")
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


func _get_interactable_text(object_id: String) -> String:
	var obj = interactables_data.get(object_id, {})
	var texts = obj.get("texts_by_stage", {})
	return texts.get(interactable_stage_id, "")


func _flash_story_label() -> void:
	if text_tween:
		text_tween.kill()
	story_label.modulate.a = 1.0
	text_tween = create_tween()
	text_tween.tween_property(story_label, "modulate:a", 0.65, 0.08)
	text_tween.tween_property(story_label, "modulate:a", 1.0, 0.12)


func _on_clock() -> void:
	story_label.text = _get_interactable_text("clock")
	GameState.flags["checked_clock"] = true


func _on_broadcast_light() -> void:
	story_label.text = _get_interactable_text("broadcast_light")
	GameState.flags["checked_broadcast_light"] = true


func _on_exit_gate() -> void:
	story_label.text = _get_interactable_text("exit_gate")
	GameState.flags["checked_exit_gate"] = true
