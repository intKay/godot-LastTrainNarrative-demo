extends Control

enum Phase { INTRO, INVESTIGATED, FINISHED }
var phase: int = Phase.INTRO

var hint_texts: Dictionary = {
	"light": "电子公告屏显示：末班车即将进站。\n第二行刷新了一次：\n灯光参数已载入。",
	"door": "电子公告屏显示：末班车即将进站。\n第二行刷新了一次：\n出口状态已载入。",
	"broadcast": "电子公告屏显示：末班车即将进站。\n第二行刷新了一次：\n广播记录已载入。",
	"ticket": "电子公告屏显示：末班车即将进站。\n第二行刷新了一次：\n日期偏差已载入。",
}

@onready var notice_btn: Button = $RootMargin/VBox/StationHBox/NoticeBoardButton
@onready var broadcast_light: ColorRect = $RootMargin/VBox/StationHBox/BroadcastLight
@onready var story_label: Label = $RootMargin/VBox/StoryLabel
@onready var choice_a: Button = $RootMargin/VBox/ChoiceAButton
@onready var choice_b: Button = $RootMargin/VBox/ChoiceBButton
@onready var choice_c: Button = $RootMargin/VBox/ChoiceCButton
@onready var choice_d: Button = $RootMargin/VBox/ChoiceDButton


func _ready() -> void:
	story_label.text = "你站在一座空车站里。\n公告屏仍在刷新。\n广播灯亮着，没有声音。\n时钟停在 23:47。"
	_hide_choices()
	notice_btn.pressed.connect(_on_notice_board)
	choice_a.pressed.connect(_on_choice_a)
	choice_b.pressed.connect(_on_choice_b)
	choice_c.pressed.connect(_on_choice_c)
	choice_d.pressed.connect(_on_choice_d)


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
		var text: String = hint_texts.get(hint, "电子公告屏显示：末班车即将进站。")
		story_label.text = text
		_show_choices()
		phase = Phase.INVESTIGATED
	elif phase == Phase.INVESTIGATED:
		story_label.text = "公告屏依旧亮着。\n你已浏览过公告屏。"
	elif phase == Phase.FINISHED:
		var label: String = GameState.last_choice_label
		story_label.text = "电子公告屏显示：23:47  末班车\n目的地：校准中\n上一行为：%s" % label


func _disable_choices() -> void:
	choice_a.disabled = true
	choice_b.disabled = true
	choice_c.disabled = true
	choice_d.disabled = true


func _update_broadcast_light(color: Color) -> void:
	broadcast_light.color = color


func _on_choice_a() -> void:
	GameState.doubt += 1
	GameState.anomaly += 1
	GameState.last_choice_label = "询问广播"
	GameState.choice_history.append("询问广播")
	GameState.current_stage = 1
	story_label.text = "广播灯亮了一下，又熄灭。\n半秒后，它用和你相同的语气问：\n“你希望这里是哪一站？”"
	_disable_choices()
	_update_broadcast_light(Color(1.0, 0.4, 0.0))
	phase = Phase.FINISHED


func _on_choice_b() -> void:
	GameState.control += 1
	GameState.last_choice_label = "查看出口"
	GameState.choice_history.append("查看出口")
	GameState.current_stage = 1
	story_label.text = "出口指示灯亮起。\n屏幕显示：离站许可尚未生成。"
	_disable_choices()
	_update_broadcast_light(Color(0.27, 0.53, 1.0))
	phase = Phase.FINISHED


func _on_choice_c() -> void:
	GameState.obedience += 1
	GameState.last_choice_label = "继续等待"
	GameState.choice_history.append("继续等待")
	GameState.current_stage = 1
	story_label.text = "广播终于响起。\n“请继续等待。故事正在保持稳定。”"
	_disable_choices()
	_update_broadcast_light(Color(0.27, 1.0, 0.27))
	phase = Phase.FINISHED


func _on_choice_d() -> void:
	GameState.doubt += 1
	GameState.last_choice_label = "保持沉默"
	GameState.choice_history.append("保持沉默")
	GameState.current_stage = 1
	story_label.text = "公告屏刷新了一次。\n没有车次，只有一行字：\n观察行为已记录。"
	_disable_choices()
	_update_broadcast_light(Color(1.0, 0.67, 0.0))
	phase = Phase.FINISHED
