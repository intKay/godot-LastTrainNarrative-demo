# 阶段 2.2：扩展第二轮车站选择 — 完成报告

## 基本信息

- **版本**：阶段 2.2
- **前置条件**：阶段 2.1 JSON 数据驱动迁移完成
- **变更性质**：新增第二轮车站主线选择
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/story_nodes.json` | 修改 | 为 `station_round_1` 4 个选项加 `next_node`；新增 `station_round_2` 节点含 4 个选项 |
| `data/interactables.json` | 修改 | 新增 `slice_end_text` 字段 |
| `scripts/station_scene.gd` | 修改 | 状态机从 3 阶段扩为 4 阶段（INTRO/INVESTIGATED/FINISHED/END）；新增 `_load_round_data()`、`_show_continue()`、`_on_continue()` 方法 |
| `docs/16_phase2_2_second_round_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`scenes/*.tscn`、`game_state.gd`、`calibration_screen.gd`、`data_loader.gd`、`main_test.*`

## story_nodes.json 新增内容

### station_round_1 选项修改

4 个选项各新增 `"next_node": "station_round_2"` 字段，指向第二轮。

### 新增 station_round_2 节点

```
visible_text: "广播灯重新亮起。电子公告屏上的车次没有变化。只有目的地一栏开始闪烁。"

4 个选项：
A. 要求系统解释刚才的记录     → doubt+1, anomaly+1, light=红色
B. 尝试改写公告屏上的目的地   → control+1, anomaly+1, light=橙色
C. 继续等待系统安排下一班车   → obedience+1, light=绿色
D. 离开选项区，检查出口       → control+1, light=蓝色
```

## station_scene.gd 核心改动

### 状态机

| 阶段 | 说明 |
|------|------|
| INTRO (0) | 每轮初始。点电子公告屏 → 显示 hint 文本 + 显示选项 → INVESTIGATED |
| INVESTIGATED (1) | 选项可见。点公告屏 → "公告屏依旧亮着"；点选项 → FINISHED |
| FINISHED (2) | 选项已选。点公告屏 → 显示"上一行为"。如有下一轮 → 显示"继续"按钮 |
| END (3) | 切片结束。点公告屏 → 显示"切片扩展结束。当前版本已记录两次主线行为。" |

### 新增方法

| 方法 | 功能 |
|------|------|
| `_load_round_data(round_id)` | 按 `round_id` 从 `story_data` 查找节点，加载 `visible_text` 和 `options`，重置广播灯到灰色 |
| `_show_continue()` | 将 ChoiceAButton 改为"继续"，隐藏 B/C/D，重连信号到 `_on_continue` |
| `_on_continue()` | 恢复 ChoiceAButton 信号，加载下一轮数据，显示 4 个选项 |

### "继续"按钮的完整流程

```
[第一轮选择后]
  choice_a.text = "继续"
  choice_b/c/d 隐藏
  choice_a.pressed → disconnect(_on_choice_a), connect(_on_continue)

[点击"继续"]
  → disconnect(_on_continue), connect(_on_choice_a)
  → choice_a.text = 第二轮第一个选项文本
  → _load_round_data("station_round_2")
  → 显示第二轮 visible_text + 4 个选项
  → phase = INVESTIGATED
```

## 第一轮旧流程是否退化

| 验收项 | 阶段 2.1 | 阶段 2.2 | 一致？ |
|--------|---------|---------|--------|
| 校准界面 | 正常 | 同左 | ✅ 未修改 |
| 校准→1.5s→车站 | 正常 | 同左 | ✅ 未修改 |
| 车站初始文本 | 正常 | 同左 | ✅ JSON 不变 |
| 公告屏 hint 4 种 | 正常 | 同左 | ✅ JSON 不变 |
| 第一轮 4 选项 | 正常 | 同左 | ✅ JSON 内容不变 |
| 第一轮反馈文本 | 正常 | 同左 | ✅ JSON 内容不变 |
| 第一轮广播灯颜色 | 正常 | 同左 | ✅ JSON 内容不变 |
| 第一轮后公告屏残影 | 正常 | 同左 | ✅ 逻辑保留 |

## 第二轮新增验收

| # | 操作 | 预期 | 结果 |
|---|------|------|------|
| 1 | 第一轮后"继续"按钮出现 | ChoiceAButton 显示"继续"，B/C/D 隐藏 | ⬜ |
| 2 | 点击"继续" | 显示第二轮文本 + 第二轮 4 个选项 | ⬜ |
| 3 | 点击第二轮选项 A/B/C/D | 反馈文本 + 广播灯变色 + 按钮禁用 | ⬜ |
| 4 | 点击电子公告屏 | 显示"上一行为：{第二轮选择}" | ⬜ |
| 5 | 再次点击电子公告屏 | 显示"切片扩展结束。当前版本已记录两次主线行为。" | ⬜ |
| 6 | Output 面板 | 无红色 error，无 JSON 报错 | ⬜ |

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| ChoiceAButton 信号重连 | `_show_continue` 和 `_on_continue` 中断开/重连顺序出错会导致按钮无响应 | 低（已用 `is_connected` 检查） |
| `has_next_round` 判断 | 以轮次级别判断是否有下一轮，忽略选项级别的 `next_node` 差异（当前所有选项指向同一节点，无差异） | 低 |
| `_load_round_data` 重置广播灯 | 每次加载轮次将广播灯重置为灰色，第二轮立即重新变色 | 低（不影响体验） |

## 回滚建议

```bash
git restore data/story_nodes.json data/interactables.json scripts/station_scene.gd
```

## 测试结果

- **测试日期**：2026-05-29
- **测试结论**：⚠️ **部分通过，2 个 Bug 待修复**

### 通过项

| 验收项 | 结果 |
|--------|------|
| 阶段 2.1 回归（校准/切换/初始文本/公告屏/第一轮） | ✅ 全部通过 |
| 第一轮后"继续"按钮出现 | ✅ |
| 点击"继续"后显示第二轮 visible_text | ✅ |
| 第二轮广播灯变色 | ✅ |
| 第二轮选项 A 选择 + 反馈文本 | ✅ |
| 第二轮后公告屏残影（"上一行为"） | ✅ |
| 第二轮后公告屏结尾文本（"切片扩展结束"） | ✅ |
| 无红色 error | ✅ |

### Bug 记录

| # | 严重度 | 描述 | 原因 | 修复方案 |
|---|--------|------|------|---------|
| 1 | 🔴 | 点击"继续"后，只有 ChoiceA 显示第二轮文本，B/C/D 文字仍为第一轮的旧文本，且 B/C/D 不可见 | `_on_continue()` 只更新了 `choice_a.text` 和调用 `_show_choices()`，但 `_load_round_data()` 中的 `_hide_choices()` 使 B/C/D 隐藏后 `_show_choices()` 未能正确恢复 | 在 `_on_continue()` 中显式为 4 个按钮设置 `text` + 逐按钮 `show()` |
| 2 | 🔴 | 第二轮选择 B/C/D 时需求无法验证（因按钮不可见） | 同 Bug 1 的根因 | 修复 Bug 1 后自然解决 |
| 3 | 🟡 | 很多信息需要点击电子公告屏才能看到，缺乏提示 | UX 设计：玩家不会自然想到需要反复点击公告屏推进流程 | 后续考虑在文本中加入引导提示，如"电子公告屏仍在更新。点击查看。" |

### 第二轮新增验收结果

| # | 操作 | 预期 | 实际 |
|---|------|------|------|
| 1 | 第一轮后"继续"按钮出现 | ChoiceA 显示"继续" | ✅ |
| 2 | 点击"继续" | 显示第二轮文本 + 4 个选项 | ❌ 仅 ChoiceA 显示，B/C/D 隐藏 |
| 3 | 点击第二轮选项 A | 反馈文本 + 变色 + 禁用 | ✅ |
| 4 | 点击第二轮选项 B/C/D | — | ❌ 按钮不可见无法测试 |
| 5 | 点击电子公告屏 | 显示"上一行为" | ✅ |
| 6 | 再次点击电子公告屏 | 显示"切片扩展结束" | ✅ |
| 7 | Output 面板 | 无红色 error | ✅ |

## 下一阶段建议

| 阶段 | 内容 |
|------|------|
| 2.3 | 加入时钟/出口门等新交互物的 JSON 配置 |
| 2.4 | 扩展校准至完整三问 |
| 2.5 | 结局系统原型 |

---

## 阶段 2.2.1 Bug 修复记录

### 修复了什么

第二轮进入时 B/C/D 按钮不可见、文字不正确、实际处于禁用状态，导致第二轮 B/C/D 无法测试。

### 根因

`_on_continue()` 只更新了 `choice_a.text` 并调用 `_show_choices()`，但：
1. `_load_round_data()` 中的 `_hide_choices()` 隐藏了全部 4 个按钮
2. 第一轮 `_make_choice()` 中的 `_disable_choices()` 使 B/C/D 保持 `disabled = true`
3. `_show_choices()` 仅恢复 `visible`，未恢复 `disabled` 和 B/C/D 的 `text`

### 修改文件

| 文件 | 操作 | 说明 |
|------|------|------|
| `scripts/station_scene.gd` | 修改 | `_on_continue()` 中 4 行替换为循环，统一恢复 4 个按钮的 text / disabled / visible |

### 具体代码变化

改前：
```gdscript
choice_a.text = round_options[0].text if round_options.size() > 0 else ""
_show_choices()
```

改后：
```gdscript
for i in range(round_options.size()):
    var btn: Button = [choice_a, choice_b, choice_c, choice_d][i]
    btn.text = round_options[i].text
    btn.disabled = false
    btn.show()
```

### 验收结果

| # | 操作 | 预期 | 结果 |
|---|------|------|------|
| 1 | F5 启动 → 校准 → 车站 | 阶段 2.1 回归正常 | ⬜ |
| 2 | 第一轮→继续→第二轮 A/B/C/D 全部可见、文字正确 | 4 个按钮状态完全恢复 | ⬜ |
| 3 | 第二轮 A/B/C/D 分别点击 | 各自反馈/变色/禁用 | ⬜ |
| 4 | 第二轮后公告屏残影 + 结尾文本 | 显示正确 | ⬜ |
| 5 | Output 面板 | 无红色 error | ⬜ |

### 遗留问题

- UX 提示不足（很多信息需点公告屏）— 仍为 🟡 待后续优化
