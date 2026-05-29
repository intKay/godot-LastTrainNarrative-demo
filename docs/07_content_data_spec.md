# 《叙事校准程序 / 末班车站》v0.1 内容数据格式规范

## 目标

所有剧情文本、选项和调查内容尽量数据驱动。新增内容时优先修改 JSON，不重写代码。

## calibration_questions.json

用于存储开场三问。

字段建议：

```json
[
  {
    "question_id": "calibration_1",
    "prompt": "请选择故事的第一个锚点：",
    "options": [
      {
        "id": "light",
        "text": "一盏整夜没有熄灭的灯",
        "state_delta": {
          "doubt": 1,
          "control": 0,
          "obedience": 0,
          "anomaly": 0
        },
        "set_flags": ["calib_light"],
        "initial_world_hint": "light"
      }
    ]
  }
]
```

字段说明：

- question_id：问题 ID
- prompt：问题文本
- options：选项数组
- id：选项 ID
- text：显示给玩家的选项文字
- state_delta：初始状态影响
- set_flags：设置的标记
- initial_world_hint：进入车站后的初始元素提示

## story_nodes.json

用于存储主线节点。

字段建议：

```json
[
  {
    "node_id": "station_round_1",
    "stage": 1,
    "visible_text": "你站在一座空车站里。",
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
        "next_node": ""
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
]
```

字段说明：

- node_id：节点 ID
- stage：车站轮次
- visible_text：主文本
- options：选项
- state_delta：选项造成的状态变化
- set_flags：选项触发的 flags
- world_changes：世界元素变化
- next_node：下一个节点

## interactables.json

用于存储可点击调查元素。

字段建议：

```json
[
  {
    "object_id": "notice_board",
    "display_name": "公告牌",
    "texts_by_stage": {
      "1": "公告牌显示：23:47，末班车即将进站。"
    },
    "set_flags_on_click": ["checked_notice_board"],
    "visual_state_by_stage": {
      "1": "normal"
    }
  }
]
```

字段说明：

- object_id：交互物 ID
- display_name：显示名称
- texts_by_stage：不同阶段调查文本
- set_flags_on_click：点击后设置的 flag
- visual_state_by_stage：不同阶段视觉状态

## 命名规范

建议统一：

- calibration_1
- station_round_1
- checked_notice_board

不要混用中文 ID 和英文 ID。显示文本可以是中文，程序 ID 建议英文。

## 数据编写原则

1. 每个选项必须有 state_delta
2. 每个选项至少应改变状态、世界元素或 flag 中的一项
3. 不要写无效果选项
4. 调查文本要短
5. 不要把所有解释塞进 JSON 文本
