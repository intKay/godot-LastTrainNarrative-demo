extends Control

var doubt: int = 0
var control: int = 0
var obedience: int = 0
var anomaly: int = 0
var last_choice: String = ""
var has_chosen: bool = false

@onready var story_label: Label = $RootMargin/VBox/StoryLabel
@onready var option_a: Button = $RootMargin/VBox/OptionAButton
@onready var option_b: Button = $RootMargin/VBox/OptionBButton
@onready var option_c: Button = $RootMargin/VBox/OptionCButton
@onready var option_d: Button = $RootMargin/VBox/OptionDButton
@onready var notice_btn: Button = $RootMargin/VBox/NoticeBoardButton


func _ready() -> void:
	story_label.text = "叙事校准程序\n请选择故事的第一个锚点。"
	option_a.pressed.connect(_on_a)
	option_b.pressed.connect(_on_b)
	option_c.pressed.connect(_on_c)
	option_d.pressed.connect(_on_d)
	notice_btn.pressed.connect(_on_notice)


func _on_a() -> void:
	doubt += 1
	last_choice = "灯"
	_choose()


func _on_b() -> void:
	control += 1
	last_choice = "门"
	_choose()


func _on_c() -> void:
	anomaly += 1
	last_choice = "广播"
	_choose()


func _on_d() -> void:
	obedience += 1
	last_choice = "车票"
	_choose()


func _choose() -> void:
	has_chosen = true
	option_a.disabled = true
	option_b.disabled = true
	option_c.disabled = true
	option_d.disabled = true
	var hint_text: Dictionary = {
		"灯": "灯光参数已载入。",
		"门": "出口状态已载入。",
		"广播": "广播记录已载入。",
		"车票": "日期偏差已载入。",
	}
	story_label.text = "校准完成。\n%s\n场景确认：末班车站。" % hint_text[last_choice]


func _on_notice() -> void:
	if not has_chosen:
		story_label.text = "公告牌显示：等待校准输入。"
	else:
		story_label.text = "公告牌显示：23:47  末班车\n目的地：校准中\n上一行为：%s" % last_choice
