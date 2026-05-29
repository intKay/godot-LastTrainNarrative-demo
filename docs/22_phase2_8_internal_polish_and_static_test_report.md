# 阶段 2.8：内部完善与代码级验收 — 完成报告

## 基本信息

- **版本**：阶段 2.8（内部验收子阶段）
- **前置条件**：阶段 2.7 结局系统 + 阶段 2.8 文本精修完成
- **变更性质**：UI 字号待办实施 + 全量 JSON 静态检查 + 三条结局路径 Python 模拟 + 代码静态分析
- **测试方式**：静态代码检查 + Python 路径模拟（**未运行 Godot F5**）

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `scenes/ending_screen.tscn` | 修改 | SystemLabel 字号 14→18，居中（阶段 2.8 遗留待办） |
| `scenes/calibration_screen.tscn` | 修改 | InstructionLabel 字号 14→16（阶段 2.8 遗留待办） |
| `docs/22_phase2_8_internal_polish_and_static_test_report.md` | 新建 | 本报告 |

**注意**：本报告不覆盖 `docs/22_phase2_8_text_ui_polish_report.md`。

## UI 微调记录

| 场景 | 节点 | 改前 | 改后 | 理由 |
|------|------|:----:|:----:|------|
| 结局画面 | SystemLabel | 字号 14，左对齐（默认） | **字号 18，居中** | 结局名称下系统标签太小且偏左，与标题不对齐 |
| 校准界面 | InstructionLabel | 字号 14 | **字号 16** | 开篇说明文字略小，可读性可改善 |

不改节点名、不改脚本引用路径、不改布局结构。

## JSON 静态检查结果

统一使用 Python 脚本验证 4 个 JSON 文件的解析、结构、字段完整性。

| 文件 | 检查项 | 结果 |
|------|--------|:----:|
| `calibration_questions.json` | 3 问各 4 选项，state_delta 含有效值，calib_1 含 initial_world_hint 覆盖 4 种 hint，calib_2/3 不含 | ✅ |
| `story_nodes.json` | 3 轮各 4 选项，next_node 链 r1→r2→r3→空，所有 state_delta 非零 | ✅ |
| `interactables.json` | 4 对象（notice_board/clock/broadcast_light/exit_gate），三轮文本齐全，notice_board 含全部残影/结束文本字段 | ✅ |
| `endings.json` | 3 结局（obedience/doubt/control），ID/title/system_label/body 完整，每结局含对应主题关键词 | ✅ |

## 三条结局路径模拟结果

使用 Python 模拟完整游玩流程（3 问校准 + 3 轮主线），按倾向选择选项，验证结局入口。

### 顺从路径

```
state:  doubt=0  control=0  obedience=6  anomaly=0
ending: obedience_ending ✅
```

选择序列：calib_1:广播 → calib_2:确认时钟 → calib_3:保留等待 → r1:等待 → r2:继续等待 → r3:接受等待

### 怀疑路径

```
state:  doubt=6  control=0  obedience=0  anomaly=4
ending: doubt_ending ✅
```

选择序列：calib_1:灯 → calib_2:确认广播 → calib_3:保留质疑 → r1:询问广播 → r2:要求解释 → r3:追问记录

### 控制路径

```
state:  doubt=0  control=6  obedience=0  anomaly=2
ending: control_ending ✅
```

选择序列：calib_1:门 → calib_2:确认出口 → calib_3:保留修改 → r1:查看出口 → r2:改写目的地 → r3:强行选择

**结论：三条不同倾向路径均正确触发对应的结局 ID。**

## 每个结局如何触发

### 顺从结局

- **触发条件**：`GameState.obedience > doubt AND obedience > control`
- **实际触发值**：obedience=6, doubt=0, control=0
- **平局处理不适用**

### 怀疑结局

- **触发条件**：`GameState.doubt > control AND doubt > obedience`
- **实际触发值**：doubt=6, control=0, obedience=0
- **平局后备 1**：anomaly > 0 → doubt_ending（当 doubt/control/obedience 非严格最大时）
- **平局后备 2**：默认 → doubt_ending
- **anomaly 不作为独立结局维度**

### 控制结局

- **触发条件**：`GameState.control > doubt AND control > obedience`
- **实际触发值**：control=6, doubt=0, obedience=0
- **平局处理不适用**

## 代码静态检查结果

### `station_scene.gd` (251 行)

| 检查项 | 结果 | 依据 |
|--------|:----:|------|
| 第三轮后进入最终判断 | ✅ | FINISHED → `has_next_round=false` → 点公告屏 → END → `_show_ending_trigger()` |
| _show_ending_trigger 只显示 ChoiceA | ✅ | `choice_b.hide()` / `choice_c.hide()` / `choice_d.hide()` |
| ChoiceA 改为"查看最终判断" | ✅ | `choice_a.text = "查看最终判断"` |
| _on_go_to_ending 切到 ending_screen | ✅ | `change_scene_to_file("res://scenes/ending_screen.tscn")` |
| 信号连接防重复 | ✅ | 3 处 `is_connected` 检查 + `disconnect` 守卫 |
| 第三轮选项禁用防刷状态 | ✅ | `_disable_choices()` 在 `_make_choice` 中 |
| 前两轮"继续"逻辑未破坏 | ✅ | `_show_continue` / `_on_continue` 未修改 |
| 调查物不修改 state_delta | ✅ | `_on_clock` / `_on_broadcast_light` / `_on_exit_gate` 只写 text + flag |

### `ending_screen.gd` (54 行)

| 检查项 | 结果 |
|--------|:----:|
| `_ready()` 加载 `data/endings.json` | ✅ |
| `_get_ending_id()` 比较最高值，处理平局 | ✅ |
| 显示 title / system_label / body | ✅ |
| body 通过 `"\n".join()` 拼接 | ✅ |
| "重新开始"调用 `GameState.reset()` | ✅ |
| 重新开始切回 `calibration_screen.tscn` | ✅ |
| JSON 找不到对应结局时有 `push_error` | ✅ |

### `game_state.gd` (25 行)

| 检查项 | 结果 |
|--------|:----:|
| 存在 `reset()` | ✅ |
| reset 清零全部 9 个字段 | ✅ |
| Autoload 未被移除 | ✅ (`project.godot` 中 `GameState="*res://scripts/game_state.gd"`) |
| 字段含义未改 | ✅ |

## Bug 修复记录

**未发现阻塞级代码问题。** 全部 JSON 解析通过、next_node 链完整、结局路径模拟全部命中、信号安全守卫齐全。

## 已知限制

1. 未运行 Godot F5，无法验证真实 UI 点击手感
2. 未做外部玩家试玩
3. 无法验证实际窗口中文字是否完全不截断
4. 只能保证数据和代码路径层面逻辑一致

## 下一步建议

1. 用户亲自用 Godot F5 跑三条路径（顺从/怀疑/控制），确认实机通过
2. 实机通过后生成 `docs/23_phase2_9_v0_1_completion_report.md` 完成报告
3. 再考虑按 `docs/10_playtest_checklist.md` 找人试玩
