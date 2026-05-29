# 叙事校准程序 / 末班车站

Godot 4.x / GDScript / Control UI 互动叙事游戏原型。v0.1 目标是 5-10 分钟本地可运行 Demo。

## 当前状态

项目处于**阶段 0**：scenes/、scripts/、data/ 目录均未创建，没有可运行的场景或脚本。
详见 `docs/08_task_list.md` 了解阶段划分。

## 必须阅读的文档

按顺序阅读（docs/ 下所有 .md 文件）：

1. `docs/00_project_overview.md` ~ `docs/10_playtest_checklist.md`（共 11 份）
2. 涉及 UI/音效/美术时额外读 `docs/06_ui_art_audio_guide.md`

## 核心约束

- Godot 4.6（`Forward Plus` 渲染器，`project.godot` 中确认）
- GDScript 唯一语言，无 C#、无 3D
- Control UI 为主（无复杂 2D 移动）
- 无真实 AI API（v0.1 用 MockAI + JSON 文本）
- 无自由文本输入、多 NPC 对话、战斗、背包、复杂谜题、动态 AI 音乐

## 开发阶段顺序

1. **阶段 0**：最小 Godot UI 玩具（Label + Button + 状态变量）
2. **阶段 1**：1 分钟垂直切片（校准 1 问 → 车站 → 公告牌 → 1 轮主线）
3. **阶段 2**：完整 v0.1（3 问 + 5 轮 + 4 调查物 + 3 结局）
4. **阶段 3**：UI/音效打磨
5. **阶段 4**：试玩审计

禁止跳阶段。先完成垂直切片再扩展完整流程。

## 目录结构约定

```
scenes/           # .tscn 场景文件
scripts/          # .gd 脚本文件
data/             # JSON 数据文件
assets/           # 美术、音效、字体
  art/
  audio/
  fonts/
docs/             # 设计文档
```

## 核心脚本职责

| 脚本 | 职责 |
|------|------|
| `game_state.gd` | Autoload 单例，记录全局状态 |
| `mock_ai_manager.gd` | 读取 JSON 并返回节点内容 |
| `calibration_screen.gd` | 开场三问处理 |
| `station_scene.gd` | 车站主场景控制 |
| `choice_panel.gd` | 选项按钮生成 + option_selected 信号 |
| `interactable_object.gd` | 调查元素点击响应 |
| `world_state_controller.gd` | 更新车站视觉状态 |
| `ending_manager.gd` | 根据 GameState 判断结局 |

## GameState 字段

```gdscript
var current_stage: int = 0
var current_node_id: String = ""
var doubt: int = 0
var control: int = 0
var obedience: int = 0
var anomaly: int = 0
var flags: Dictionary = {}
var choice_history: Array = []
```
`doubt`/`control`/`obedience`/`anomaly` 是**唯一四种状态键**。调查点击只设 flag，不反复增减状态。

## JSON 数据结构关键要求

- story_nodes.json: 每个节点必须有 `node_id`, `stage`, `visible_text`, `options`, `world_changes`, `set_flags`
- 每个 option: `id`, `text`, `state_delta`, `set_flags`, `world_changes`, `next_node`
- 每轮 3-4 个选项，禁止分支爆炸
- `world_changes` 只使用：`notice_board`, `clock`, `broadcast_light`, `exit_gate`
- 节点 ID 用英文，稳定可读（如 `station_round_1`, `ending_doubt`）

## 叙事文本风格

**必须**：短、冷、准、有信息量、克制、系统化、有轻微刺痛感。
**每句话至少做一件事**：反馈选择 / 提供信息 / 推进认知 / 暗示记录 / 引导下一步 / 误导或揭示。
**禁止**：长篇散文、过度文艺、过早说"你被测试了"、鬼怪惊吓、纯氛围描写。

## 验证流程

每次修改后报告：
1. 修改了哪些文件
2. 实现了什么
3. 如何在 Godot 中验证（F6 运行哪个场景、点击什么按钮、观察什么变化）
4. 剩余风险

## 可用命令

- `plan-slice` — 规划下一步垂直切片
- `implement-task` — 实现指定编码任务
- `review-godot` — 审查场景/脚本质量
- `review-text` — 审查叙事文本
- `validate-data` — 验证 JSON 数据

## 加载 skill 获取上下文

- `godot-4-ui-prototype` — 实现/修改场景、UI、信号、JSON 加载前先加载
- `narrative-calibration-design` — 编写/审查叙事文本前加载
- `json-content-pipeline` — 编辑 JSON 数据前加载
- `playtest-risk-review` — 新增机制前加载

## 安全规则

- 不改动 `project.godot` 引擎配置以外的字段
- 不删除用户文档（docs/ 下的 .md 文件）
- 不写入 API key 或凭据
- 不引入外部插件除非明确要求
- 不一次性改太多无关文件
- 不确定时先问用户，不自行假设
