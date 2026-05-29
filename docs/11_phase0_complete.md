# 阶段 0：Godot 最小 UI 玩具 — 实现与验收报告

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `scenes/main_test.tscn` | 新建 | Godot 4.6 场景，Control 根节点 + 深色背景 + MarginContainer + VBoxContainer 布局 |
| `scripts/main_test.gd` | 新建 | 70 行 GDScript，6 个状态变量 + 5 个信号连接 + 选项逻辑 + 公告牌逻辑 |
| `project.godot` | 修改 | `[application]` 新增 `run/main_scene="res://scenes/main_test.tscn"` |

未修改：`docs/`、`AGENTS.md`、`opencode.json`、`icon.svg*`。

## 验收结果（已玩家测试通过）

| 编号 | 验收项 | 状态 |
|------|--------|------|
| 1 | Godot 4.6 可直接运行 | ✅ |
| 2 | 初始界面显示"叙事校准程序"标题 + 分隔线 + 故事文本 + 5 个 Button | ✅ |
| 3 | 点击 A：`doubt += 1`，`last_choice = "灯"`，文本显示"灯光参数已载入" | ✅ |
| 4 | 点击 B：`control += 1`，`last_choice = "门"`，文本显示"出口状态已载入" | ✅ |
| 5 | 点击 C：`anomaly += 1`，`last_choice = "广播"`，文本显示"广播记录已载入" | ✅ |
| 6 | 点击 D：`obedience += 1`，`last_choice = "车票"`，文本显示"日期偏差已载入" | ✅ |
| 7 | 选择后 4 个选项 Button 全部禁用（`disabled = true`） | ✅ |
| 8 | 公告牌（选择前）：显示"等待校准输入" | ✅ |
| 9 | 公告牌（选择后）：显示"22:47 末班车 / 目的地：校准中 / 上一行为：{灯/门/广播/车票}" | ✅ |
| 10 | 所有可点击项均为 Button 类型，无 Label 误用 | ✅ |
| 11 | 无 Autoload、无 JSON、无外部依赖、无 API key 写入 | ✅ |

## 运行方式

1. 打开 Godot 4.6 → Import → 选择 `last-train-1-min/project.godot`
2. 按 **F5** 或点击播放按钮
3. 默认加载 `scenes/main_test.tscn`

## 故障排查

| 症状 | 优先检查 |
|------|----------|
| 启动后黑屏/无 UI | `project.godot` 第 17 行 `run/main_scene` 路径是否正确 |
| "Invalid get index 'StoryLabel'" | `main_test.gd:10` 的 `$RootMargin/VBox/StoryLabel` 与 TSCN 节点树不一致 |
| "Script not found" | `main_test.tscn:3` 的 `path="res://scripts/main_test.gd"` 文件是否存在 |
| 按钮点击无反应 | `_ready()` 中 `pressed.connect` 是否被注释或拼写错误 |

## 风险与回滚

- **风险**：`project.godot` 新增的 `run/main_scene` 行不影响其他配置。删除该行即可恢复。
- **回滚**：删除 `scenes/main_test.tscn`、`scripts/main_test.gd`，以及 `project.godot` 第 17 行即可完全回退。

## 进入阶段 1（一分钟垂直切片）前需补充

1. `scripts/game_state.gd` — Autoload 全局状态
2. `scenes/calibration_screen.tscn` + `scenes/station_scene.tscn` — 场景拆分
3. `data/calibration_questions.json` + `data/story_nodes.json` — 数据驱动
4. 广播灯 ColorRect 视觉反馈
5. 公告牌差异化调查文本（依据 calibration_hint）

阶段 0 的 `main_test.tscn` 在阶段 1 中保留为独立技术验证场景，不删除。
