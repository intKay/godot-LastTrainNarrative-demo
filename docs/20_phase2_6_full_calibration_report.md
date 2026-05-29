# 阶段 2.6：扩展校准至完整三问 — 完成报告

## 基本信息

- **版本**：阶段 2.6
- **前置条件**：阶段 2.5 调查物时机优化 + StoryLabel 闪烁完成
- **变更性质**：校准界面从单问扩展为三问循环
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/calibration_questions.json` | 重写 | 从 1 问扩展为 3 问，每问 4 个选项含非零 state_delta |
| `scripts/calibration_screen.gd` | 重写 | 单问硬编码→多问循环（逐问显示→选择→delta→下一问→完成切场景） |
| `docs/20_phase2_6_full_calibration_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`game_state.gd`、`data_loader.gd`、`station_scene.gd`、所有 `.tscn`、`main_test.*`

## 为什么这样改

### 旧系统问题

1. `_load_data()` 硬编码读取 `data[0]` — 只支持一问
2. `_on_option_selected()` 选择后立即"校准完成"→切场景 — 无多问流程
3. `state_delta` 全部为零且从未被读取 — 校准对状态系统无实际影响
4. 脚本中未应用 `state_delta`、`set_flags` — JSON 字段存在但代码未消费

### 新系统设计

- 加载所有问题到 `questions_data` 数组，逐问显示
- `_on_option_selected` 实际读取并累加 `state_delta`、标记 `set_flags`
- 仅 calibration_1 的选项带 `initial_world_hint`（对应公告屏 4 种差异文本）
- calibration_2/3 不带该字段，不覆盖第一问的 world hint
- 三问完成后进入原有"校准完成→切场景"流程

## 三问校准数据结构

```json
calibration_1: 请选择故事的第一个锚点
  A. 一盏整夜没有熄灭的灯      → doubt+1, anomaly+1, hint=light
  B. 一扇始终没有打开的门      → control+1, hint=door
  C. 一段无人回应的广播        → obedience+1, hint=broadcast
  D. 一张写错日期的车票        → anomaly+1, hint=ticket

calibration_2: 进入场景后，主角最先确认什么？
  A. 出口是否真实存在          → control+1
  B. 广播是否在回应自己        → doubt+1
  C. 时钟是否还在走            → obedience+1
  D. 公告屏是否显示目的地      → anomaly+1

calibration_3: 当故事开始偏离时，主角保留什么？
  A. 继续等待的理由            → obedience+1
  B. 质疑规则的习惯            → doubt+1
  C. 修改结果的冲动            → control+1
  D. 不被记录的沉默            → anomaly+1
```

每问 4 选项各对应一种特质，三轮可均匀积累每个特质 +3。

## calibration_screen.gd 核心改动

### 新增变量

```gdscript
var questions_data: Array = []       # 完整三问数据
var current_question_index: int = 0  # 当前问题索引 (0-2)
var current_options: Array = []      # 当前问题的选项数组
```

### 新增方法

| 方法 | 功能 |
|------|------|
| `_display_question(index)` | 清旧按钮→设问题文本→建新按钮→恢复 UI 可见性 |
| `_clear_buttons()` | 遍历 `buttons_vbox`，`queue_free()` 所有 Button |
| `_create_buttons()` | 按 `current_options` 动态创建 Button，按 index 绑定信号 |
| `_enable_all_buttons()` | 遍历按钮恢复 `disabled = false` |
| `_finish_calibration()` | 隐藏标题/说明/问题，显示"校准完成"，1.5s 后切场景 |

### 改造方法

| 方法 | 改前 | 改后 |
|------|------|------|
| `_load_data()` | 读 `data[0]`，设 question_label + options_data | 存完整 `questions_data`，调 `_display_question(0)` |
| `_on_option_selected(hint, label, btn)` | 只设 hint/label/choice_history，不读 delta | 读取 `state_delta`/`set_flags`/choice_history/world_hint，禁用按钮→判断是否有下问→有则 0.5s 后显示→无则 `_finish_calibration` |

### 状态应用逻辑

```gdscript
var delta = opt.get("state_delta", {})
GameState.doubt += delta.get("doubt", 0)
GameState.control += delta.get("control", 0)
GameState.obedience += delta.get("obedience", 0)
GameState.anomaly += delta.get("anomaly", 0)

var flags = opt.get("set_flags", [])
for f in flags:
    GameState.flags[f] = true

GameState.choice_history.append(opt.get("last_choice_label", ""))
GameState.last_choice_label = opt.get("last_choice_label", "")

if opt.has("initial_world_hint"):
    GameState.initial_world_hint = opt.initial_world_hint
```

## 验收结果

### 校准新增流程

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 校准界面正常：标题 + 说明 + 问题 + 4 Button | ✅ |
| 2 | 第一问文字"请选择故事的第一个锚点：" | ✅ |
| 3 | 第一问选项 A/B/C/D 正确 | ✅ |
| 4 | 选择后按钮禁用 → 0.5s → 第二问 | ✅ |
| 5 | 第二问文字"进入场景后，主角最先确认什么？" | ✅ |
| 6 | 第二问选项按钮刷新，旧按钮已清除 | ✅ |
| 7 | 第二问选择后 0.5s → 第三问 | ✅ |
| 8 | 第三问文字"当故事开始偏离时，主角保留什么？" | ✅ |
| 9 | 第三问选择后按钮禁用 → "校准完成" | ✅ |
| 10 | 1.5s 后自动切换到车站场景 | ✅ |
| 11 | GameState 状态值正确累加（三问各+1） | ✅ |
| 12 | `initial_world_hint` 由第一问决定（后两问不覆盖） | ✅ |
| 13 | 无红色 error / JSON 报错 | ✅ |
| 14 | 无 `UNUSED_PARAMETER` 编译警告 | ✅ |

### 回归测试

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 第一轮主线（公告屏→选项→反馈→继续） | ✅ |
| 2 | 第二轮主线（同上） | ✅ |
| 3 | 第三轮主线（选项→三次记录→最终残影） | ✅ |
| 4 | 四调查物（时钟/广播灯/出口门各 3 轮文本） | ✅ |
| 5 | 主线按钮不可重复点击 | ✅ |
| 6 | 调查物不影响 state values / phase | ✅ |

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| `_display_question` 中 `queue_free` 可能残留信号 | Button 被 `queue_free` 释放，信号自动断开 | 低（Godot 4 自动管理） |
| `await` 期间玩家快速操作 | 按钮已 `disabled = true`，await 前已阻断二次点击 | 低 |
| calibration 状态值从零变为非零 | 这是预期行为 — 校准首次产生状态影响 | 低 |
| 第三问选择后屏幕短暂空白（0.5s 后进入完成） | 0.5s 极短，玩家几乎无感知 | 低 |

## 回滚建议

```bash
git restore data/calibration_questions.json scripts/calibration_screen.gd
```

## 下一阶段 2.7 建议

阶段 2.7：三个低保真结局

- 创建 `data/endings.json`（顺从/怀疑/控制三结局 ID + 条件 + 文本）
- 创建 `scenes/ending_screen.tscn` + `scripts/ending_screen.gd`
- `station_scene.gd` 第三轮结束后判断最高状态值→切结局场景
- 结局文本保持冷淡系统风格，不说教，用 UI 语言描述系统如何解读玩家选择
- 允许玩家重新开始以体验不同结局
