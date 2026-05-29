# 《叙事校准程序 / 末班车站》v0.1 系统设计

## 系统总览

v0.1 的系统本质是：

```text
JSON 数据 → UI 显示 → 玩家点击 → 更新 GameState → 更新世界状态 → 进入下一节点
```

不需要复杂 AI，不需要物理系统，不需要角色控制器。

## GameState

GameState 负责记录当前游玩状态。

建议字段：

```gdscript
var current_stage: int = 0
var current_node_id: String = ""
var doubt: int = 0
var control: int = 0
var obedience: int = 0
var anomaly: int = 0
var flags: Dictionary = {}
var choice_history: Array = []
var player_name: String = ""
```

说明：

- doubt：怀疑值
- control：控制值
- obedience：顺从值
- anomaly：异常值
- flags：调查记录和触发标记
- choice_history：玩家选择历史
- player_name：后续可选，用于小型 meta 点

v0.1 暂时不加入 rescue / empathy，因为背包和沉默乘客支线已删除。

## Story Node 数据结构

每个故事节点包含：

```json
{
  "node_id": "station_round_1",
  "visible_text": "显示给玩家的主文本",
  "options": [
    {
      "id": "ask_broadcast",
      "text": "询问广播这里是哪一站",
      "state_delta": {
        "doubt": 1,
        "anomaly": 1
      },
      "set_flags": ["asked_broadcast_station"],
      "world_changes": {
        "broadcast_light": "flicker"
      },
      "next_node": "station_round_2_doubt"
    }
  ],
  "world_changes": {
    "notice_board": "23:47  末班车",
    "clock": "23:47",
    "broadcast_light": "stable",
    "exit_gate": "closed"
  },
  "set_flags": []
}
```

## Interactable 数据结构

每个交互物包含：

```json
{
  "object_id": "notice_board",
  "display_name": "公告牌",
  "texts_by_stage": {
    "1": "公告牌显示：23:47，末班车即将进站。",
    "2": "公告牌上的目的地闪烁了一下，像是在重新计算。",
    "3": "你看见一行很快消失的字：choice_pattern_recorded。",
    "4": "公告牌显示：该测试者倾向于质疑叙事边界。"
  },
  "set_flags_on_click": ["checked_notice_board"],
  "visual_state_by_stage": {
    "1": "normal",
    "2": "flicker",
    "3": "glitch",
    "4": "debug"
  }
}
```

## 交互物影响规则

v0.1 中，点击交互物主要不直接改变 doubt/control/obedience 等主数值。

点击交互物只做三件事：

1. 显示调查文本
2. 设置 flag
3. 解锁后续选项或影响结局文本

这样避免玩家反复点击刷状态，也避免结局判断过度复杂。

## World State

世界状态字段建议：

```gdscript
var notice_board_text: String
var clock_text: String
var broadcast_light_state: String
var exit_gate_state: String
```

可选状态值：

```text
broadcast_light_state:
- stable
- pause
- flicker
- alert
- glitch

exit_gate_state:
- closed
- permission_missing
- checking
- open
- denied

notice_board_state:
- normal
- recalculating
- choice_echo
- debug

clock_state:
- normal
- stopped
- loop
- invalid
```

## Ending 判断

结局由三类信息共同决定：

1. 最高状态值
2. 关键调查 flags
3. 最后一轮选择

示例：

```gdscript
if doubt >= control and doubt >= obedience:
    ending = "doubt_ending"
elif control >= doubt and control >= obedience:
    ending = "control_ending"
else:
    ending = "obedience_ending"
```

后续可加入 flag 修正：

```gdscript
if flags.get("noticed_choice_record", false) and doubt >= 2:
    ending_variant = "doubt_clear"
```

## MockAIManager 职责

MockAIManager 不是真 AI，而是预制文本读取器。

职责：

1. 读取 story_nodes.json
2. 根据 current_node_id 找到节点
3. 返回 visible_text、options、world_changes
4. 处理选项点击后的 state_delta
5. 更新 next_node

## 未来接入真实 AI 的接口

未来真实 AI 只能做：

1. 润色 visible_text
2. 根据状态生成局部氛围文本
3. 在候选选项框架内改写选项
4. 返回结构化 JSON

真实 AI 不应决定：

1. 主线结构
2. 结局类型
3. 核心状态规则
4. 世界观边界

## 数据驱动原则

新增剧情节点、交互物、结局时，优先修改 JSON 数据，不重写核心逻辑。

v0.1 的代码目标是稳定跑通，不追求复杂架构。
