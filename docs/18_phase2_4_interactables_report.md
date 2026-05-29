# 阶段 2.4：补全时钟广播灯出口门调查物 — 完成报告

## 基本信息

- **版本**：阶段 2.4
- **前置条件**：阶段 2.3 第三轮车站选择完成
- **变更性质**：新增时钟/广播灯/出口门三个可调查交互物
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `scenes/station_scene.tscn` | 修改 | 在 StationHBox 与 StoryLabel 之间新增 InteractHBox 含 3 个 Button |
| `data/interactables.json` | 修改 | 追加 clock / broadcast_light / exit_gate 三个对象，各含 3 轮 texts_by_stage |
| `scripts/station_scene.gd` | 修改 | 新增 3 个 @onready、3 个信号绑定、interactables_data 字典填充、3 个调查 handler + 1 个辅助方法 |
| `docs/18_phase2_4_interactables_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`data/story_nodes.json`、`scenes/main_test.tscn`、`game_state.gd`、`data_loader.gd`、`calibration_screen.gd`

## 新增调查物

| 对象 ID | 显示名称 | 按钮文本 | 每轮文本递进 |
|---------|----------|---------|-------------|
| `clock` | 时钟 | 时钟 | 1: 23:47 秒针没有移动 → 2: 分钟短暂变 23:46 → 3: 屏幕显示"记录时长不足" |
| `broadcast_light` | 广播灯 | 广播灯 | 1: 亮着没声音 → 2: 闪了一下等待你说话 → 3: 不再伪装成设备 |
| `exit_gate` | 出口门 | 出口门 | 1: 离站许可未生成 → 2: 许可生成中 → 3: 开了一条缝等待最终判断 |

## interactables.json 新增字段

3 个对象均使用以下结构（以 clock 为例）：

```json
{
  "object_id": "clock",
  "display_name": "时钟",
  "texts_by_stage": {
    "station_round_1": "...",
    "station_round_2": "...",
    "station_round_3": "..."
  },
  "set_flags_on_click": ["checked_clock"]
}
```

已有 `notice_board` 对象的数据和字段 **完全不变**。

## station_scene.gd 核心改动

### 1. 新增变量

```gdscript
var interactables_data: Dictionary = {}
@onready var clock_btn: Button = $RootMargin/VBox/InteractHBox/ClockButton
@onready var broadcast_light_btn: Button = $RootMargin/VBox/InteractHBox/BroadcastLightButton
@onready var exit_gate_btn: Button = $RootMargin/VBox/InteractHBox/ExitGateButton
```

### 2. 数据加载 — 从只读 notice_board 泛化为全量加载

```gdscript
for obj in interact_data:
    interactables_data[obj.object_id] = obj
    if obj.object_id == "notice_board":
        notice_board_data = obj
```

### 3. 当前轮次判断

使用现有 `current_round_id` 变量（`"station_round_1"` / `"station_round_2"` / `"station_round_3"`），由 `_load_round_data()` 在点击"继续"时设置。

### 4. 辅助方法

```gdscript
func _get_interactable_text(object_id: String) -> String:
    var obj = interactables_data.get(object_id, {})
    var texts = obj.get("texts_by_stage", {})
    return texts.get(current_round_id, "")
```

### 5. 三个调查 handler

```gdscript
func _on_clock() -> void:
    story_label.text = _get_interactable_text("clock")
    GameState.flags["checked_clock"] = true
```

广播灯/出口门同理（仅 object_id 不同），不修改 `doubt/control/obedience/anomaly`，不改变 `phase`，不影响主线按钮。

## 交互规则

- 调查按钮始终可见，不依赖 phase
- 点击后仅显示文本 + 设置 GameState.flags 对应值
- 不调用 `_show_choices()` / `_hide_choices()` / `_show_continue()` / `_disable_choices()`
- 不修改 `doubt/control/obedience/anomaly`
- 不修改 `phase`
- 公告屏点击仍然覆盖 story_label，恢复 phase 对应的主线文本

## 回归验证

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 校准界面正常 | ✅ |
| 2 | 第一轮：公告屏→选项→继续 | ✅ |
| 3 | 第二轮：公告屏→选项→继续 | ✅ |
| 4 | 第三轮：公告屏→选项→三次记录→最终残影 | ✅ |
| 5 | 主线按钮不可重复点击 | ✅ |
| 6 | 无红色 error / JSON 错误 | ✅ |

## 新增调查物验收

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 3 个新按钮可见，文本为"时钟"/"广播灯"/"出口门" | ✅ |
| 2 | 第一轮点击时钟 → "23:47。秒针没有移动。" | ✅ |
| 3 | 第一轮点击广播灯 → "广播灯亮着。没有声音传出来。" | ✅ |
| 4 | 第一轮点击出口门 → "离站许可尚未生成。" | ✅ |
| 5 | 第二轮时钟 → "分钟数字短暂变成 23:46" | ✅ |
| 6 | 第二轮广播灯 → "像是在等待你的下一句话" | ✅ |
| 7 | 第二轮出口门 → "许可生成中" | ✅ |
| 8 | 第三轮时钟 → "记录时长不足" | ✅ |
| 9 | 第三轮广播灯 → "不再伪装成设备" | ✅ |
| 10 | 第三轮出口门 → "等待最终判断" | ✅ |
| 11 | 点击调查物后 doubt/control/obedience/anomaly 不变 | ✅ |
| 12 | 点击调查物后主线 A/B/C/D 按钮状态不变 | ✅ |
| 13 | GameState.flags 含 checked_clock / checked_broadcast_light / checked_exit_gate | ✅ |
| 14 | 调查物不影响"继续"按钮 | ✅ |
| 15 | 调查物不影响公告屏 phase 分支 | ✅ |

## 玩家反馈与记录

### 交互物更新时机（已记录，待后续决定）

当前 `current_round_id` 在 `_load_round_data()`（点击"继续"时）更新，因此调查物文本在"点击继续后"才体现下一轮状态。可优化方向：

- 在 `_make_choice()` 中提前设 `current_round_id = next_node`，让调查物在"选择后立即"反映变化，增强"世界实时反应"的沉浸感
- 第三轮（无 `next_node`）保持 `current_round_id = "station_round_3"`，不受影响

此修改需在 `_make_choice()` 中增加一行 `current_round_id = opt.get("next_node", current_round_id)`，并在 `_load_round_data()` 中验证不会产生冲突。

### 文本递进沉浸感（已记录，待阶段 2.5）

visible_text 的文本闪烁动效仍在待办中。参数：`Tween` 对 `StoryLabel.modulate.a` 做 1.0 ⇄ 0.7 循环。

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| `texts_by_stage` 缺少轮次 key | `_get_interactable_text` 返回 `""` 会清空 story_label | 低（3 个对象 3 轮齐全） |
| 调查物可能覆盖重要主线文本 | 玩家在 FINISHED 阶段点调查物会覆盖反馈文本，但点公告屏可恢复 | 🟡 设计取舍 |
| 按钮可见性 | 调查按钮始终可见，不会与主线按钮混淆 | 低 |

## 回滚建议

```bash
git restore scenes/station_scene.tscn data/interactables.json scripts/station_scene.gd
```

## 下一阶段建议

| 阶段 | 内容 |
|------|------|
| 2.5 | 文本闪烁动效 + 交互物更新时机优化 |
| 2.6 | 扩展校准至完整三问 |
| 2.7 | 结局系统原型 |
