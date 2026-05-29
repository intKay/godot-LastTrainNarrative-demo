# 阶段 2.3：扩展第三轮车站选择 — 完成报告

## 基本信息

- **版本**：阶段 2.3
- **前置条件**：阶段 2.2 第二轮选择 + 2.2.1 Bug 修复完成
- **变更性质**：新增第三轮车站主线选择 + 公告屏最后一轮适配
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/story_nodes.json` | 修改 | `station_round_2` 4 个选项各加 `"next_node": "station_round_3"`；新增 `station_round_3` 节点含 4 个选项 |
| `data/interactables.json` | 修改 | 新增 `three_rounds_end_text` 和 `echo_text_final` 字段 |
| `scripts/station_scene.gd` | 修改 | `_on_notice_board()` 中 FINISHED/END 分支适配最后一轮；原有逻辑无退化 |
| `docs/17_phase2_3_third_round_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`scenes/*.tscn`、`game_state.gd`、`data_loader.gd`、`calibration_screen.gd`

## story_nodes.json 新增内容

### station_round_2 选项修改

4 个选项各新增 `"next_node": "station_round_3"` 字段，指向第三轮。

### 新增 station_round_3 节点

```
visible_text: "电子公告屏停止刷新。\n广播灯保持常亮。\n出口指示牌亮起。上面记录着你的每一次选择。"

4 个选项：
A. 追问系统为什么记录这些行为    → doubt+1, anomaly+1, light=红
B. 强行选择一个目的地           → control+1, anomaly+1, light=橙
C. 接受系统安排，继续等待        → obedience+1, light=绿
D. 不再回应，直接走向出口        → control+1, doubt+1, light=蓝
```

所有 round_3 选项均无 `next_node`，触发系统判定为最后一轮。

## station_scene.gd 核心改动

### `_on_notice_board()` 逻辑变化

```gdscript
# 改前
elif phase == Phase.FINISHED:
    var label = GameState.last_choice_label
    var template = notice_board_data.get("echo_text_template", ...)
    story_label.text = template % label
    if not has_next_round:
        phase = Phase.END
elif phase == Phase.END:
    story_label.text = notice_board_data.get("slice_end_text", ...)

# 改后
elif phase == Phase.FINISHED:
    var label = GameState.last_choice_label
    if not has_next_round:
        # 最后一轮 → 先显示结束语
        story_label.text = notice_board_data.get("three_rounds_end_text", ...)
        phase = Phase.END
    else:
        # 前两轮 → 显示残影（原逻辑不变）
        var template = notice_board_data.get("echo_text_template", ...)
        story_label.text = template % label
elif phase == Phase.END:
    var label = GameState.last_choice_label
    var template = notice_board_data.get("echo_text_final", ...)
    story_label.text = template % label  # 显示"等待最终判断"残影
```

### next_node 链式加载验证

当前 `_make_choice()` 使用 `opt.get("next_node", "")` 泛化读取，`_load_round_data(round_id)` 按 ID 加载，`_on_continue()` 用 `next_round_id` 跳转——**全部支持链式加载**，无需修改状态机结构。

### interactables.json 新增字段

| 字段 | 用途 |
|------|------|
| `three_rounds_end_text` | 最后一轮公告屏首次点击："当前版本已记录三次主线行为。下一阶段将根据状态生成结局判断。" |
| `echo_text_final` | 最后一轮公告屏二次点击："电子公告屏显示：23:47 末班车 目的地：等待最终判断 上一行为：%s" |

保留 `echo_text_template`（用于前两轮）和 `slice_end_text`（向后兼容，实际不再触发）。

## 回归验证

### 阶段 2.1 回归

| # | 验收项 | 结果 |
|---|--------|------|
| 1 | F5 启动进入校准界面 | ✅ |
| 2 | 校准 4 个 Button（非 Label） | ✅ |
| 3 | 校准选择后按钮禁用 | ✅ |
| 4 | 1.5s 后切换到车站场景 | ✅ |
| 5 | 车站初始文本正确 | ✅ |
| 6 | 公告屏 hint 4 种差异文本 | ✅ |
| 7 | 第一轮 4 个选项显示、可点 | ✅ |
| 8 | 第一轮反馈文本 + 广播灯变色 | ✅ |
| 9 | 第一轮后公告屏残影 | ✅ |

### 阶段 2.2 第二轮回归

| # | 验收项 | 结果 |
|---|--------|------|
| 1 | 第一轮后"继续"按钮出现 | ✅ |
| 2 | 点击"继续"→ 第二轮 visible_text + 4 选项 | ✅ |
| 3 | 第二轮 A/B/C/D 全部可见、可点 | ✅ |
| 4 | 第二轮反馈 + 变色 + 禁用 | ✅ |
| 5 | 第二轮后公告屏残影 + 继续按钮 | ✅ |

## 第三轮新增流程验收

| # | 验收项 | 操作 | 结果 |
|---|--------|------|------|
| 1 | 第三轮 visible_text | 第二轮后点"继续" | ✅ |
| 2 | 第三轮 4 按钮全部可见、文字正确 | 点公告屏 → 选项出现 | ✅ |
| 3 | A. 追问记录 → 反馈 + 红 + 禁用 | 点击 A | ✅ |
| 4 | B. 强行改写 → 反馈 + 橙 + 禁用 | 点击 B | ✅ |
| 5 | C. 接受等待 → 反馈 + 绿 + 禁用 | 点击 C | ✅ |
| 6 | D. 走向出口 → 反馈 + 蓝 + 禁用 | 点击 D | ✅ |
| 7 | 第三轮后公告屏→"三次记录"文本 | 首次点击公告屏 | ✅ |
| 8 | 再次点击→"等待最终判断"残影 | 二次点击公告屏 | ✅ |
| 9 | 无红色 error / JSON 报错 | Output 面板 | ✅ |

### 每个第三轮选项的状态变化和反馈

| 选项 | doubt | control | obedience | anomaly | 灯光 | 反馈关键句 |
|------|:-----:|:-------:|:---------:|:-------:|:----:|-----------|
| A. 追问记录 | +1 | - | - | +1 | 🔴 | "广播灯没有闪烁。它直接回答：因为你一直在要求解释。" |
| B. 强行改写 | - | +1 | - | +1 | 🟠 | "目的地一栏被你改成了空白。系统很快补上一行：用户控制倾向过高。" |
| C. 接受等待 | - | - | +1 | - | 🟢 | "广播灯稳定。感谢配合。故事可以按预期结束。" |
| D. 走向出口 | +1 | +1 | - | - | 🔵 | "出口门没有上锁。但屏幕显示：离站许可需要最终判断。" |

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| `has_next_round` 轮次级判断 | 假设一轮内所有选项一致（有/无 next_node），当前确实如此 | 低 |
| 第三轮后无强制引导 | 玩家需自主点击公告屏推进，无 UI 提示 | 🟡 已知遗留 |
| `slice_end_text` 不再被触发 | 保留但实际失效，无影响 | 低 |

## 回滚建议

```bash
git restore data/story_nodes.json data/interactables.json scripts/station_scene.gd
```

## 玩家反馈与后续计划

### 反馈 1：沉浸感不足 — 文本闪烁动效（待实现）

**问题**：三轮 visible_text 的递进感只通过文字体现，缺少视觉变化。

**方案**（计划在后续阶段实现）：
- `_load_round_data()` 中设置 `story_label.text` 后，用 `Tween` 对 `StoryLabel.modulate.a` 做几个周期的淡入淡出（1.0 ⇄ 0.7），模拟电子屏刷新闪烁
- 仅作用于每轮 visible_text 加载时，不影响反馈/公告屏文本
- 不需修改 .tscn，仅改 `station_scene.gd` 约 5 行

### 反馈 2：文本不清晰 — 第三轮 visible_text 已更新

**原文本**：
> 出口指示牌第一次显示了你的选择记录。

**新文本**（已更新到 story_nodes.json）：
> 出口指示牌亮起。上面记录着你的每一次选择。

增强"系统一直在记录"的揭示感和情感冲击。

### 下一阶段建议

| 阶段 | 内容 |
|------|------|
| 2.4 | 四个调查物完整化（时钟/广播灯/出口门交互） |
| 2.5 | 文本闪烁动效 + 其他 UI 微反馈 |
| 2.6 | 扩展校准至完整三问 |
| 2.7 | 结局系统原型 |
