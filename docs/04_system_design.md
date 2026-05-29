# 《叙事校准程序 / 末班车站》v0.1 / v0.2 系统设计

## 系统总览

v0.1 的系统本质是：

```text
JSON 数据 → UI 显示 → 玩家点击 → 更新 GameState → 更新世界状态 → 进入下一节点
```

v0.2 的系统本质是：

```text
JSON 数据 + Mock AI → UI 显示 + 设备视觉化 + 音效 → 玩家点击 → 更新 GameState → dominant_trait 计算 → 车站空间反馈 → 进入下一节点
```

不需要复杂 AI，不需要物理系统，不需要角色控制器。

## GameState

GameState 负责记录当前游玩状态。

### v0.1 核心字段（不可变）

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
- anomaly：异常值（叙事噪声/系统失真值，不决定结局类型）
- flags：调查记录和触发标记
- choice_history：玩家选择历史
- player_name：后续可选，用于小型 meta 点

### v0.2 新增字段

```gdscript
var dominant_trait: String = ""          # "doubt" | "control" | "obedience" | "mixed"
var ai_session_id: String = ""           # AI 会话 ID，重开时刷新
var ai_guidance_used: bool = false       # 本局是否已触发 AI 引导
var ai_rewritten_option_slot: String = ""  # 被 AI 改写的选项槽位
var ai_rewritten_option_text: String = ""  # AI 改写后的文本
var audio_enabled: bool = true           # 音效开关
```

### dominant_trait 计算规则

第一版计算规则：

```text
如果 doubt 最大 → "doubt"
如果 control 最大 → "control"
如果 obedience 最大 → "obedience"
如果三者平局或接近 → "mixed"
```

`anomaly` 不作为主倾向，它表示叙事噪声/系统失真值，影响文本语气、设备失真、刷新强度、音效失真和 AI 触发条件。

> v0.1 完整原型：GameState 当前已实现，后续不再移除字段，只增量添加。

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
```

## Interactable 数据结构

每个交互物包含：

```json
{
  "object_id": "notice_board",
  "display_name": "电子公告屏",
  "texts_by_hint": {
    "light": "电子公告屏显示：23:47，末班车即将进站。"
  },
  "investigated_text": "公告屏依旧亮着。\n你已浏览过公告屏。",
  "echo_text_template": "电子公告屏显示：23:47  末班车\n目的地：校准中\n上一行为：%s",
  "set_flags_on_click": ["checked_notice_board"]
}
```

v0.1 包含四个交互物：电子公告屏、时钟、广播灯、出口门。各自在 `interactables.json` 中配置。

## 交互物影响规则

v0.1 中，点击交互物主要不直接改变 doubt/control/obedience 等主数值。

点击交互物只做三件事：

1. 显示调查文本
2. 设置 flag
3. 为后续选项提供条件

这样避免玩家反复点击刷状态。

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

## MockAI / AI 引导系统（v0.2）

### MockAIManager（v0.1 现有）

MockAIManager 不是真 AI，而是预制文本读取器。

职责：

1. 读取 story_nodes.json
2. 根据 current_node_id 找到节点
3. 返回 visible_text、options、world_changes
4. 处理选项点击后的 state_delta
5. 更新 next_node

### v0.2 AI 定位

v0.2 AI 是"AI 原生雏形"，不是完整 AI 原生系统。

v0.2 AI 只能做：

1. 动态引导文本（根据玩家状态生成系统解释）
2. 系统解释文本（总结玩家上一行为）
3. 受限选项显示文本改写（改写一个选项的显示文字）

v0.2 AI 不能做：

1. 自由输入
2. 生成完整主线
3. 生成结局
4. 决定 state_delta / next_node / ending_id
5. 新增角色 / 场景 / 选项数量
6. 绕过本地验证
7. 决定结局类型

### AI 幻觉控制

AI 只能提到允许对象：

```text
电子公告屏 / 时钟 / 广播灯 / 出口门 / 末班车站
记录 / 解释请求 / 目的地 / 离站许可 / 系统建议
最终判断 / 叙事噪声 / 校准 / 选择历史
```

禁止提到：

```text
列车员 / 乘客 / 怪物 / 真实城市 / 车厢内部
站外场景 / 隐藏房间 / 真实逃脱路线 / 第四结局
新 NPC / 不在 UI 中存在的物件
```

### AI 上下文控制

每次 AI 请求必须使用显式状态包，不依赖模型历史记忆。重新开始时必须生成新的 session_id，清空本地 AI 缓存。

### AI 延时与 fallback

AI 请求可能延时 3-4 秒，等待期间显示"系统正在解释上一行为……"并禁用相关按钮。4 秒超时使用 Mock fallback。

### 默认模式

v0.2 默认不依赖真实 API。默认使用 Mock AI 动态引导 + Mock 选项改写。API 仅作实验开关。

### 真实 AI 接口（未来扩展）

未来真实 AI 只能做：

1. 润色 visible_text
2. 根据状态生成局部氛围文本
3. 在候选选项框架内改写选项
4. 返回结构化 JSON

真实 AI 不应决定：

1. 主线结构
2. 核心状态规则
3. 世界观边界

## 数据驱动原则

新增剧情节点、交互物时，优先修改 JSON 数据，不重写核心逻辑。

v0.1 的代码目标是稳定跑通，不追求复杂架构。

## 结局系统（低保真设计）

### 触发方式

三问 + 三轮选择结束后，比较 `doubt`、`control`、`obedience` 三个值的最高维度。

- `obedience` 最高 → 顺从结局
- `doubt` 最高 → 怀疑结局
- `control` 最高 → 控制结局
- `anomaly` 不影响结局判断，仅用于文本中的异常强度

### 数据来源

`endings.json`（阶段 2.6 时创建），包含三个结局的 ID、触发条件判断和结局文本。

### 显示方式

结束当前车站场景后，加载 `ending_screen.tscn` 显示对应结局文本。允许玩家重新开始以体验不同结局。

### 设计原则

- 不突然说教
- 不直接解释"你在被测试"
- 结局用冷淡 UI 语言描述系统如何解读玩家的选择模式
