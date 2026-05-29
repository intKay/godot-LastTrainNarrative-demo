# 阶段 2.7：结局系统原型 — 完成报告

## 基本信息

- **版本**：阶段 2.7
- **前置条件**：阶段 2.6 三问校准完成
- **变更性质**：新增三个低保真结局 + 第三轮结束后"查看最终判断"切入 + 重新开始功能
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/endings.json` | **新建** | 三个结局的 ID/标题/系统标签/正文 |
| `scenes/ending_screen.tscn` | **新建** | 低保真结局界面 |
| `scripts/ending_screen.gd` | **新建** | 结局判断 + 显示 + 重新开始 |
| `scripts/game_state.gd` | **修改** | 新增 `reset()` 方法 |
| `scripts/station_scene.gd` | **修改** | 新增 `_show_ending_trigger()`、`_on_go_to_ending()`；END handler 追加触发 |
| `docs/21_phase2_7_endings_report.md` | **新建** | 本报告 |

**未修改**：`project.godot`、`data/story_nodes.json`、`data/interactables.json`、`data/calibration_questions.json`、`calibration_screen.*`、`data_loader.gd`

## 结局判断规则

```
取 GameState.doubt / control / obedience 三者最高值。

obedience > doubt AND obedience > control → obedience_ending
control > doubt AND control > obedience → control_ending
doubt > control AND doubt > obedience → doubt_ending

平局处理：
  如果 anomaly > 0 → doubt_ending
  仍平局 → 默认 doubt_ending
```

**anomaly 不作为独立结局维度**，仅作为平局打破因子。

## endings.json 数据结构

```json
{
  "ending_id": "obedience_ending",
  "title": "结局：顺从",
  "system_label": "稳定叙事完成",
  "body": ["行1", "行2", "行3", "行4", "行5", "行6", "行7"]
}
```

三个结局各 7 行 body 文本。详见 `data/endings.json`。

## station_scene.gd 如何触发结局

### 新增方法

| 方法 | 功能 |
|------|------|
| `_show_ending_trigger()` | 将 ChoiceAButton 设为"查看最终判断"，隐藏 B/C/D，断开旧信号，连接 `_on_go_to_ending` |
| `_on_go_to_ending()` | `change_scene_to_file("res://scenes/ending_screen.tscn")` |

### 触发流程

```
第三轮选择 → phase=FINISHED, has_next_round=false
  ↓ 点公告屏（第1次）
FINISHED handler → "三次记录"文本 → phase=END
  ↓ 点公告屏（第2次）
END handler → echo_text_final 残影 → _show_ending_trigger()
  ↓ ChoiceA 显示"查看最终判断"
  ↓ 点击 → ending_screen
```

### 信号安全

`_show_ending_trigger()` 先断开 `_on_choice_a` 和 `_on_continue`（通过 `is_connected` 检查），再连接 `_on_go_to_ending`，避免重复连接或残留。

前两轮"继续"按钮使用的 `_show_continue` / `_on_continue` 流程完全不受影响。

## ending_screen.gd 如何读取和显示结局

1. `_ready()` → 加载 `data/endings.json` → 调用 `_get_ending_id()` → `_show_ending()`
2. `_get_ending_id()` 比较 `doubt/control/obedience` 最高值，处理平局
3. `_show_ending()` 遍历 `endings_data` 匹配 `ending_id`，设 `title_label` / `system_label` / `body_label`
4. `_on_restart()` → `GameState.reset()` → `change_scene_to_file("calibration_screen.tscn")`

## 重新开始如何重置 GameState

### game_state.gd 新增 `reset()` 方法

```gdscript
func reset() -> void:
    current_stage = 0
    current_node_id = ""
    doubt = 0
    control = 0
    obedience = 0
    anomaly = 0
    flags = {}
    choice_history = []
    initial_world_hint = ""
    last_choice_label = ""
```

不移除 Autoload 节点（不破坏 `GameState` 跨场景引用），只清零全部运行时字段。

## Godot 中如何验收

见下方验收结果表。

## 三类结局测试结果

### 验收完整流程

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | F5 → 三问校准 | ✅ |
| 2 | 第一轮主线（公告屏→选项→反馈→继续） | ✅ |
| 3 | 第二轮主线（同上） | ✅ |
| 4 | 第三轮主线（选项→反馈） | ✅ |
| 5 | 第三轮后点公告屏→"三次记录"文本 | ✅ |
| 6 | 再点公告屏→"等待最终判断"残影 + "查看最终判断"按钮 | ✅ |
| 7 | 点击"查看最终判断"→ 结局场景 | ✅ |
| 8 | 结局场景显示标题 + 系统标签 + 正文 | ✅ |
| 9 | 点"重新开始" → 回到校准界面 | ✅ |
| 10 | 重新开始后 GameState 清零 | ✅ |

### 三倾向路径测试

校准三问 + 三轮主线按倾向选择，确认三个结局入口：

| 测试路径 | 预期结局 | 结果 |
|---------|---------|:----:|
| 全程选等待/配合类（obedience 最高） | 顺从结局 | ✅ |
| 全程选追问/质疑类（doubt 最高） | 怀疑结局 | ✅ |
| 全程选改写/出口/控制类（control 最高） | 控制结局 | ✅ |

### 回归测试

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 校准界面正常（3 问） | ✅ |
| 2 | 四调查物（时钟/广播灯/出口门各 3 轮） | ✅ |
| 3 | 主线按钮不可重复点击 | ✅ |
| 4 | 调查物不影响 state values / phase | ✅ |
| 5 | StoryLabel 闪烁 | ✅ |
| 6 | 调查物选择后提前反映下一轮状态 | ✅ |
| 7 | 无红色 error / JSON 报错 | ✅ |
| 8 | 无 `UNUSED_PARAMETER` 编译警告 | ✅ |

## 玩家反馈与待优化（不修改）

### 1. 结局文案需增加文学性

当前三个结局偏记录式罗列（"系统确认：用户持续XXX"）。建议加入 1–2 句意象描写：
- 顺从结局：车门关闭后车厢灯光一盏一盏熄灭的意象
- 怀疑结局：问题列表比广播内容更长的对比
- 控制结局：风从站内吹向站外的倒错感

修改范围仅限 `data/endings.json`，不动脚本。留待阶段 2.8 统一打磨。

### 2. UI 交互鼠标移动过大

整局流程中，玩家需在顶部公告屏（第一行按钮区）和底部选项区（ChoiceA/B/C/D）之间反复切换：
- 每轮 INTRO 阶段：点公告屏🟠 → 选选项🔵
- 每轮 FINISHED 阶段：点"继续"🔵
- 第三轮 END 阶段：点公告屏🟠（×2）→ 点"查看判断"🔵

三轮下来约切换 10–12 次。对于 3–5 分钟流程属可接受范围。优化方案（不改当前布局）：
- 底部加"查看公告屏"按钮
- 公告屏旁加"继续"按钮

留待阶段 2.8 评估是否需要调整。

## 已知风险

| 风险 | 级别 | 说明 |
|------|:----:|------|
| ChoiceAButton 信号冲突 | 低 | `_show_ending_trigger` 断开旧信号再连新信号；切场景后自动清理 |
| GameState 重开未完全重置 | 低 | `reset()` 清零全部 9 个字段，不遗漏 |
| 结局路径测试需走完整流程 | 🟡 | 每次到达结局需 3 校准 + 3 轮选择，约 2 分钟/次 |
| 结局文本平淡 | 🟡 | 已在反馈中记录，待 2.8 打磨 |

## 回滚建议

```bash
git restore scripts/station_scene.gd scripts/game_state.gd
git rm data/endings.json scenes/ending_screen.tscn scripts/ending_screen.gd
```

## 下一阶段建议

阶段 2.8：文本精修 + 低保真 UI 统一

- 结局文案增强文学性（data/endings.json）
- 评估 UI 交互布局是否需优化
- 统一全项目文本风格
- 按钮悬停 / 轻微视觉反馈
- 不新增玩法功能，只打磨已有内容

## 项目状态

**v0.1 功能闭环已完成。** 核心链条闭环：

```
校准 3 问 → GameState 初始状态
  → 车站 3 轮主线 → GameState 累加
    → 4 调查物每轮递进文本
      → 最高状态判断 → 3 个结局之一
        → 重新开始 → 状态清零 → 回到校准
```

下一阶段（2.8）不做新功能，只打磨已有内容。
